---
draft: true
exam_objectives:
- Interoperability with Notifications, Observability, and Continuous Integration Tools
---
# Build Artifacts And The CI To Engine Contract

Continuous integration and a GitOps engine solve different problems. CI turns source code into an artifact and checks it. The engine makes a cluster match a desired state. Between them there is a contract: CI produces something that can be named exactly, and the desired state in Git refers to that name. This part explains the contract, who writes to what, and which identifiers keep it trustworthy.

## What CI produces

A build produces an artifact, most often a container image in a registry. The registry stores the image under a content digest, a hash of the image manifest, and under tags, which are names that can be moved. A build can also produce a packaged Helm chart, a signed bundle, a software bill of materials, or a test report. Only the first two are inputs to a delivery. The others are evidence about the artifact.

CI does not deploy in a GitOps design. It finishes when the artifact exists and is checked. The next step is a change of the desired state that names the artifact, and this change is what the engine reads.

## Two ways to hand over

There are two designs for the handover.

In the first design, CI writes the new image reference into Git. The step edits the image tag in an overlay or in chart values, commits, and pushes, or opens a pull request. The engine sees a new commit and applies it. Git holds the full history of what was deployed and who changed it. Nothing in the cluster needs to know about the registry.

In the second design, the engine side watches the registry and writes the change itself. Flux has image controllers for this: one scans a repository for tags, one applies a policy such as the highest semantic version, and one commits the new tag to Git. Argo CD has a separate project, Argo CD Image Updater, with the same goal. The commit to Git still happens, but the automation makes it, not the CI job.

```mermaid
flowchart LR
  B["CI build"] --> R["Registry"]
  B -->|"design one: commit"| G["Git"]
  R -->|"design two: scan and commit"| I["Image automation"]
  I --> G
  G --> E["Engine"]
  E --> C["Cluster"]
```

The diagram shows both designs ending in a commit. In both, Git is the single place where the desired state changes, and the engine never takes an image from the registry on its own.

## Authority at each step

Each tool should hold only the access it needs.

- The CI job needs to push images to the registry. It needs write access to the Git repository only in the first design, and then only to the path or branch that holds image references. A pull request with review keeps CI from changing the production state without a person.
- The engine needs read access to Git and to the registry. It does not need write access to Git unless image automation is on. It needs permission in the cluster to create the objects it manages.
- A person who reads the result needs read access only.

A credential shared by all three is a single point of failure. If the CI credential can also change the cluster, a compromised build job can deploy anything. If the engine credential can write to Git, a compromised cluster can rewrite its own desired state.

## Identifiers that carry provenance

Provenance is the record of where an artifact came from. The identifiers that carry it are chained.

1. The source commit of the application, which CI built from.
2. The image digest, which the registry assigned to the build.
3. The commit in the deployment repository that references the image.
4. The revision of the Git artifact that the engine fetched.
5. The image that runs in the Pod.

A tag such as `latest` or `6.15.0` breaks the chain, because the tag can later point to another image. A digest does not. When the reference in Git is a digest, the running image can be compared with the build record. When it is a tag, the registry must be trusted not to move it. Signing and attestations add proof of who built the image, but they are separate from the engine, which only applies what Git says unless an admission policy checks the signature.

## What a CI success signal means

A green CI run means that the pipeline steps returned success. It does not mean that the change is deployed. The engine may not have fetched the commit yet, may be paused, may have failed to apply, or may have applied it to a workload that does not become ready. A pipeline that reports "deployed" after it pushed a commit is reporting something it cannot know.

To close the loop, CI can wait on the engine. In Flux, a job can wait for a Kustomization to become `Ready` with the revision it expects. In Argo CD, a job can wait for the Application to report the expected sync revision and a `Healthy` status. These are polling reads of the status that the engine already publishes. The alternative is to let the engine send a notification to the CI system or to chat when the result is known.

## Try it: follow one change through the chain

The playground delivers the staging overlay with Flux. Act as the CI job: push a change to Git, make Flux fetch it, and read every identifier on the way.

<!-- astrona:playground:renew -->

Clone the repository, change the message of the overlay, and push. The port forward on 3000 is already open.

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
sed -i.bak 's/value: staging$/value: staging-ci/' overlays/staging/message.yaml && rm overlays/staging/message.yaml.bak
git add -A
git -c user.name=ci -c user.email=ci@starfleet.local commit -m "Release from CI"
git push origin main
git rev-parse HEAD
```

The last command prints the commit you pushed. The source fetches every hour, so ask it to fetch now, then ask the Kustomization to apply:

```sh
STAMP="$(date +%s)"
kubectl -n flux-system annotate gitrepository/scout --overwrite reconcile.fluxcd.io/requestedAt="$STAMP"
kubectl -n flux-system annotate kustomization/scout-staging --overwrite reconcile.fluxcd.io/requestedAt="$STAMP"
kubectl -n flux-system wait kustomization/scout-staging --for=condition=Ready --timeout=240s
```

Read the chain from the source to the workload:

```sh
kubectl -n flux-system get gitrepository scout -o jsonpath='{.status.artifact.revision}{"\n"}'
kubectl -n flux-system get kustomization scout-staging -o jsonpath='{.status.lastAppliedRevision}{"\n"}'
kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging | grep -E '"(version|message)"'
```

Both revisions end with the commit that `git rev-parse` printed, and the message in the response is the new one. The image tag in this repository is a tag, not a digest, so the last link of the chain depends on the registry.

## Reading a break in the chain

When the new behaviour does not appear, compare the identifiers from the left. If the source revision is old, the source did not fetch. If the source is new and the applied revision is old, the Kustomization did not apply, which is a pause, a failure or a wait for the interval. If both are new and the workload is old, the rollout did not finish. Each position has a different owner and a different fix, and the comparison finds the position without guessing.

## Common pitfalls

> [!WARNING]
> A CI job that reports success after it pushed a commit has not delivered anything. Read the revision the engine applied and the state of the workload before you call a release done, and do not give the CI credential more access than the one path it must change.

Moving a tag after the engine applied it does not trigger anything, because the manifest text did not change. The cluster keeps the old image until a pod restarts, and then it may pull the new one. This is why the desired state should name a digest, or a tag that is never moved.

Another pitfall is a long polling interval. The default of a few minutes is fine for most work, but it explains why a merged change is not live at once. A webhook from Git to the engine removes the delay without a shorter interval.

Key facts:

- CI builds and checks an artifact, and the desired state in Git names it.
- Git is the single place where the desired state changes, also with image automation.
- Each tool gets only the access it needs, and CI does not hold cluster credentials.
- A digest identifies content, a tag does not.
- A green CI run does not prove a deployment.

