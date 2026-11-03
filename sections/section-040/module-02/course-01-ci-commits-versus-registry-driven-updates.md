---
draft: true
exam_objectives:
- Interoperability with Notifications, Observability, and Continuous Integration Tools
---
# CI Commits Versus Registry-Driven Updates

A GitOps repository holds the desired state, and the desired state names an image tag. When a build produces a new image, the tag in Git must change before the cluster follows. There are two designs for who makes that change. This part describes both, compares them, and shows the questions that decide between them.

## Design one: the CI job writes to Git

In the first design, the same pipeline that builds the image also changes the deployment repository. After the image is pushed, a last job clones the repository, edits the tag, commits and pushes. A typical edit is `kustomize edit set image` or a `yq` command on a values file. The engine sees the commit and rolls it out.

```mermaid
flowchart LR
  B["CI build"] --> R["registry"]
  B -->|"commit new tag"| G["deploy repository"]
  G --> E["engine"]
  E --> C["cluster"]
```

The diagram shows CI pushing the image to the registry and the tag change to Git, and the engine reading only Git.

What this design gives:

- The tag change happens at the moment of the build, so there is no polling delay.
- The pipeline knows the commit, the build number and the test results, and can put them in the commit message.
- The cluster needs no access to the registry for scanning.

What it costs:

- CI holds write access to the deployment repository. A compromised pipeline can then change what runs in every environment that follows that branch.
- Every pipeline needs the same editing step, and each team writes its own.
- Two builds that finish at the same time can race to push, and one push is rejected and must be retried with a rebase.

## Design two: the cluster watches the registry

In the second design, a component in the cluster scans the registry, applies a rule to the tags it finds, and commits the chosen tag to Git. CI only builds and pushes the image. It has no access to the deployment repository.

```mermaid
flowchart LR
  B["CI build"] --> R["registry"]
  A["automation in cluster"] -->|"list tags"| R
  A -->|"commit chosen tag"| G["deploy repository"]
  G --> E["engine"]
```

The diagram shows the automation reading tags from the registry and writing the choice to Git, so CI is not involved after the push.

What this design gives:

- CI has no write access to the deployment repository. The write access sits in one place, with one credential, in the cluster.
- The rule for which tag is chosen, such as a version range, is written once and reviewed.
- Every environment can follow a different rule against the same registry.

What it costs:

- A polling interval adds delay between the push and the commit.
- The cluster needs read access to the registry, and write access to Git.
- The commits are made by a bot, so reviewers must trust the rule instead of reading each change.

## Design three: a mix

Many teams combine the two. CI builds, tests and signs the image, then pushes it with a tag that follows a pattern, such as a semantic version for releases and a `rc` suffix for candidates. The automation in each cluster follows only the releases. Production is not updated by an automation at all, and a person or a promotion pipeline copies the tag from staging to the production overlay in a reviewed pull request.

## Questions that decide

- Who is allowed to write to the deployment repository? If the answer is "no pipeline", use a registry-driven update.
- How fast must a build reach the cluster? If seconds matter, a CI commit with a webhook is faster than a polling interval.
- Is the tag chosen by a rule or by a person? A rule such as "newest 6.15 patch" fits automation. A decision such as "release this build" fits a CI step or a pull request.
- What does the audit need? A commit by a bot with a clear message is fine for staging. Production usually needs a named approver.

## Immutability and digests

Both designs have the problem from the module on OCI artifacts: a tag can be moved to another image. If the registry allows a tag to be overwritten, the cluster can run a different image under the same tag, with no commit in Git. Two protections exist. The registry can enforce tag immutability, so that a push to an existing tag fails. Or the repository can pin the digest, written as `image@sha256:...`, which names the content. Flux image automation can write the digest with a marker that ends in `:digest`, which gives both a readable tag and an exact pin.

## Try it: see the current pin

Run these commands in the playground:

<!-- astrona:playground:renew -->

```sh
kubectl -n flux-system get gitrepository scout
kubectl -n flux-system get kustomization scout-staging
kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}'
```

The image shows tag `6.14.0`. Clone the repository from your machine with `git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git` and read `overlays/staging/kustomization.yaml`. The `newTag` line has a trailing comment. That comment is a marker, and the next two parts explain what reads it. Make the CI-driven change by hand: edit `newTag` to `6.15.0`, commit and push. The Kustomization applies it within the interval. Change it back to `6.14.0` before the lab.

## Common mistakes

- Giving every pipeline write access to every deployment repository.
- Letting an automation update production without a review.
- Relying on a mutable tag such as `latest` and expecting Git to show what runs.
- Forgetting that a polling interval is a delay, and that a short interval raises the load on the registry.

## Check yourself

- Which design keeps the write credential out of CI?
- Why does a registry-driven design need a rule for choosing a tag?
- What two measures stop a tag from silently pointing at a different image?
