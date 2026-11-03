---
draft: true
exam_objectives:
- State Store Systems (Git and alternatives)
---
# Git As A State Store: Commits, Branches And Tags

A GitOps engine reads the desired state from a store. The store has one job that matters here: when the engine asks for a version, it must get the same content every time and it must be able to say which version it is. This part explains how Git meets that job, which names Git offers for a version, and how Argo CD turns a name into one commit.

## What a commit is

Git stores every file as an object whose name is a hash of its content. A tree object lists file names with their hashes. A commit object points at one tree and at its parent commit or commits, and it adds an author, a time and a message. The name of the commit is the hash of all of that, so the commit ID depends on the files and on the whole chain of parents.

This has two consequences. If any file or any earlier commit differs, the commit ID differs. If the commit ID is the same, the content is the same. A full commit ID has 40 hexadecimal characters. A short form is only a prefix and can become ambiguous in a large repository, so tools that must be exact use the full form.

```mermaid
flowchart LR
  C1["commit 1"] --> C2["commit 2"]
  C2 --> C3["commit 3"]
  B["branch main"] -.->|"points at"| C3
  T["tag v1.0.0"] -.->|"points at"| C1
```

The diagram shows a chain of commits. The branch `main` and the tag `v1.0.0` are names that point at commits. The commits are the versions.

## Branches and tags are names

A branch is a file in the repository that holds one commit ID. When someone pushes a new commit to the branch, the file holds the new ID. A branch therefore moves forward by design, and it means "the newest work on this line".

A tag is also a file that holds a commit ID, but the convention is that it does not change after it is created. Git does not enforce that. A person with write access can delete a tag and create it again on another commit, and a push with the force option can replace it. Some hosting services add rules that forbid this, but those rules belong to the service and not to Git.

An annotated tag is a separate object with its own ID, a message and a tagger. It points at a commit. A lightweight tag is only the file with the commit ID. When a tool resolves an annotated tag, it must follow the tag object to the commit it points at. Argo CD does this, and the commit that it records is the commit and not the tag object.

## How Argo CD resolves a revision

The field `spec.source.targetRevision` of an Application holds the revision to read. It can be a branch name, a tag name, a full commit ID, a semantic version range such as `1.*`, or empty. An empty value means the default branch of the remote, which is `HEAD`.

The repo-server component does the resolving. It keeps a local copy of the repository, asks the remote for the references, and finds the commit that the name points at. It then renders the manifests from that commit. The Application controller compares the result with the live objects. The commit that was used is written to `status.sync.revision`.

```mermaid
flowchart LR
  A["targetRevision"] --> R["repo-server resolves"]
  G["Git remote"] --> R
  R --> K["one commit ID"]
  K --> M["render from that commit"]
  K --> S["status.sync.revision"]
```

The diagram shows that the name enters the repo-server and that one commit ID leaves. Everything after that step works on the commit.

The repo-server does not ask the remote at every second. By default the controller refreshes an Application about every three minutes, and a webhook from the Git host can trigger an earlier refresh. A person can force a refresh with the annotation `argocd.argoproj.io/refresh`. The value `hard` also drops the cached manifests. Between refreshes the Application keeps working with the commit it resolved last.

## Try it: read the resolved commit

Use the playground to see a branch become a commit. The repository has two releases on `main` and a tag `v1.0.0` on the first one.

<!-- astrona:playground:renew -->

List the references of the repository through the Git port forward on port 3000:

```sh
git ls-remote http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
```

Each line has a commit ID and a reference name. Note the ID of `refs/heads/main` and the ID of `refs/tags/v1.0.0`. They are different, because `main` has moved on after the release.

Save this as `application-scout-branch.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-branch
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

Apply it and read the commit that Argo CD used:

```sh
kubectl apply -f application-scout-branch.yaml
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-branch --timeout=240s
kubectl -n argocd get application scout-branch -o jsonpath='{.status.sync.revision}'
```

The printed ID is the ID of `main` that you noted. The Application was written with a branch name, and the status holds the commit. This is the value to use when you must say which version ran.

## Why the commit is the evidence

A branch name answers "what is the newest work". It cannot answer "what ran yesterday", because the branch pointed at another commit then. A status that only says `main` would not help in an incident. For this reason Argo CD stores the resolved commit, and the sync history stores a commit for each sync.

The commit ID also links the cluster to the review. A reviewer approved a change, the change became a commit, and the commit ID in the Application status shows that this exact change is the one that ran. If a person changed an object in the cluster by hand, the live object no longer matches the commit, and the comparison shows it.

## What a commit does not prove

A commit ID proves which content was read. It does not prove that the content is correct, that the image tags in it still exist, or that the person who wrote the commit was the person named as the author. Git author fields are text that the committer can set to any value. Proof of origin needs a signature.

A commit ID also does not say which state the cluster is in. The cluster state can differ because of a failed sync, a manual change or a controller that adds fields. The Application status for `sync.status` and `health.status` says whether the live state matches the commit and whether it works.

## Common pitfalls

> [!WARNING]
> Do not treat a branch name or a tag name as a version. Both can point at another commit later without any change in the Application. Record the commit ID from `status.sync.revision` when you need to say what ran, and expect a tag to be movable unless the Git host forbids moving it.
