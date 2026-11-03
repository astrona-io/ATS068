---
draft: true
exam_objectives:
- State Store Systems (Git and alternatives)
---
# Pinning Versions And Resolving Selectors

Some environments must follow new work, and some must stay on a version that people reviewed and approved. The field `targetRevision` of an Argo CD Application decides which of the two happens. This part explains the four kinds of value, what each one does when new commits arrive, how to pin to a fixed commit, and where Argo CD keeps the record of what it deployed.

## Four kinds of target revision

A branch name follows the newest commit on that branch. An Application with `targetRevision: main` moves to every new commit on `main` after the next refresh. This is the usual choice for an environment that should always reflect the current work, such as a staging environment.

A tag name selects the commit that the tag points at. When the tag is not moved, the Application stays on that commit. Tags are common for releases because the name carries a meaning, for example `v1.0.0`. The weakness is that a tag is a movable reference, so the commit behind it can change without any edit to the Application.

A semantic version range selects the highest tag that matches the range. For example, `1.*` matches the tags `1.0.0` and `1.4.2` but not `2.0.0`, and Argo CD takes the highest match. The Application moves forward when a new matching tag appears. Argo CD supports ranges for Git tags and for chart versions in a Helm repository. A range is a controlled form of following: new releases inside the range are accepted, and releases outside it are not.

A full commit ID selects exactly one commit. No later push, tag move or branch change can alter it. This is the only value that cannot change meaning. The cost is that a person must edit the Application to change the version, and the 40-character ID is hard to read.

```mermaid
flowchart LR
  B["branch"] -->|"follows new commits"| F["moves"]
  R["version range"] -->|"follows matching tags"| F
  T["tag"] -->|"fixed unless moved"| X["can be moved"]
  C["commit ID"] -->|"never changes"| Y["fixed"]
```

The diagram sorts the four kinds by whether the selected commit can change without an edit to the Application.

## Choosing a pin

The right value depends on the environment and on who controls the change. A development environment usually follows a branch, because the goal is fast feedback. A production environment usually follows a reviewed release. Teams then choose between a tag, a range and a commit ID. A tag is easy to read, and it is safe when the Git host forbids moving tags. A commit ID is safe everywhere. Some teams keep the readable tag in the repository and let a pipeline write the matching commit ID into the Application, so a person gets both.

A pin also has a cost. An Application pinned to a commit does not receive fixes that are made on the branch. The team must raise the pin on purpose. The Application status will show `Synced` for the pinned commit even when the branch is far ahead, because the Application compares the cluster with the pinned commit and not with the branch.

## Try it: pin to a release

The repository has a tag `v1.0.0`. The tag points at the first release, where the staging overlay uses the image tag `6.14.0`. The branch `main` has a second release with `6.15.0`.

<!-- astrona:playground:renew -->

Read the commit of the tag and keep it in a variable:

```sh
TAG_COMMIT=$(git ls-remote http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git refs/tags/v1.0.0 | cut -f1)
echo "$TAG_COMMIT"
```

Save an Application that uses this commit. The variable is filled into the file by the shell, so use the unquoted marker `YAML` below:

```sh
cat > application-scout-pinned.yaml <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-pinned
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: $TAG_COMMIT
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
YAML
```

Apply it and compare the image with the one of the branch:

```sh
kubectl apply -f application-scout-pinned.yaml
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-pinned --timeout=240s
kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}'
```

The image tag is `6.14.0`, the version of the first release, although `main` is ahead. Change `targetRevision` to `main` and apply again, and the image becomes `6.15.0` after the next sync.

## What a moved tag does

You can see in a clone why a tag is not a safe pin. In a local clone, create a new commit and move the tag to it with `git tag -f v1.0.0`. Nothing in the Application changes. If you then pushed the tag with the force option, the next refresh of an Application that follows the tag name would resolve to the new commit and deploy it. No person edited the Application, and no commit on the branch carries the change. Do not push this to the shared repository. Run it only in the local clone to read how the reference changes.

## Where Argo CD keeps the record

Each sync that an Application runs is added to the list `status.history`. An entry holds the commit, the time of the deployment, the ID of the entry and the source that was used. The field `spec.revisionHistoryLimit` sets how many entries are kept. The default is 10. Older entries are removed, so the history is a short list for operators and not a long-term audit log.

The Argo CD command `argocd app rollback` uses this history to go back to an earlier entry. It is not allowed while automated sync is on, because the controller would sync to the current Git state again at the next refresh. A rollback that lasts is a change in Git.

For a long audit trail, keep the commits in Git, send the Argo CD events to a log or a notification system, and keep the repository history that the commit IDs point at. An ID in a record is useful only while the commit still exists in the repository.

## Common pitfalls

> [!WARNING]
> A pinned Application stays `Synced` while the branch moves far ahead, so a green status does not mean the environment is current. Track pins on purpose, raise them through a reviewed change, and never reuse a tag name for a different commit.
