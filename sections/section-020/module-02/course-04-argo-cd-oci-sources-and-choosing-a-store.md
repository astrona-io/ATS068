---
draft: true
exam_objectives:
- State Store Systems (Git and alternatives)
---
# Argo CD With OCI Sources, And Choosing A Store

Argo CD began as a Git tool, and Git is still its default. Newer versions also read content from OCI registries. This part explains the two OCI source forms in Argo CD, what the Application fields mean for each, and then compares Git and a registry as state stores so that the choice rests on stated needs.

## Two OCI forms in Argo CD

The first form is a Helm chart stored in an OCI registry. This form has existed for years. The Application source sets `repoURL` to the registry address without a scheme, `chart` to the chart name, and `targetRevision` to the chart version. Argo CD needs a repository entry of type `helm` with `enableOCI: true` so it uses the OCI protocol instead of a classic Helm index file.

The second form is a plain manifest artifact, like the Flux artifact in the previous parts. Argo CD 3.1 added OCI sources for this. The `repoURL` starts with `oci://`, and `targetRevision` can be a tag or a digest. The `path` selects a folder inside the unpacked artifact. After unpacking, Argo CD treats the folder like any other source path: it can be a Directory, a Kustomize base or a Helm chart. The layout is the same as for a Git path.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-oci
  namespace: argocd
spec:
  project: default
  source:
    repoURL: oci://registry.example.com/scout-manifests
    targetRevision: 1.0.0
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
```

This block is shown to read, not to apply in the playground, because the playground has Flux and its registry speaks plain HTTP. Registry credentials for Argo CD live in a repository Secret, in the same way as Git credentials, with the type set for OCI. As with Git, the repo-server resolves the revision and caches the result per digest.

## What changes for the engine

Most of the reconciliation is unchanged. The repo-server fetches the artifact, renders it, and the application controller compares and applies. Three things differ from Git.

First, the revision shown in the Application status is the tag or digest, not a commit ID. Second, a hard refresh is how you force the repo-server to ask the registry again, as with a moving branch. Third, `targetRevision` has no branch: a tag that moves behaves like a branch that moves, and a digest behaves like a commit.

Flux reaches the same result with different objects. In Flux the source controller does the fetching and exposes a stored artifact. In Argo CD the repo-server fetches on demand and caches. The comparison matters when you debug: a Flux problem with a fetch shows on the `OCIRepository`, and an Argo CD problem shows as a condition on the Application.

## Comparing Git and a registry

Use the same questions that the module on Git used.

- History. Git keeps a graph of commits with authors and messages. A registry keeps independent artifacts. History must be kept elsewhere, usually in Git.
- Review. A pull request reviews a Git change before it merges. A registry has no review step. The review happens in the repository from which the pipeline builds, so the registry artifact is a build output.
- Identity of a version. A Git commit ID covers the content and its history. An OCI digest covers the content only.
- Access. Git servers give per-repository, per-branch access and signed commits. Registries give per-repository push and pull access and signed artifacts.
- Recovery. A Git revert is a new commit. A registry rollback means pointing the reference back to an older tag or digest, which must still exist.
- Network. Clusters in restricted networks often reach only the registry that serves their images. The same registry can serve their manifests.

A common design uses both. Humans work in Git, where history and review live. CI builds an artifact from a merged commit and pushes it. The engine follows the artifact. The artifact's annotation names the commit, which brings the history back. This design costs a pipeline, and it makes the pipeline the only writer of the registry.

## Try it: compare a Git revision with an artifact revision

The playground still has the Git repository from the other modules. Compare the two kinds of revision strings. Save this as `gitrepository-scout.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: scout
  namespace: flux-system
spec:
  interval: 1m
  url: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  ref:
    branch: main
  secretRef:
    name: scout-readonly
```

Apply it:

```sh
kubectl apply -f gitrepository-scout.yaml
```

Then read the revision of the Git source and of the OCI source from the earlier parts:

```sh
kubectl -n flux-system get gitrepository scout -o jsonpath='{.status.artifact.revision}'
kubectl -n flux-system get ocirepository scout-oci -o jsonpath='{.status.artifact.revision}'
```

The Git revision has the form `main@sha1:` followed by a commit ID. The OCI revision has the form `1.0.0@sha256:` followed by a digest. The first half of each revision is a human name, a branch or a tag. The second half is the identity of the content: a SHA-1 commit ID for Git and a SHA-256 digest for OCI. In both stores a durable record of a delivery contains the second half.

## Credentials and trust

Both engines need credentials to read a private registry. In Argo CD, a repository Secret in the `argocd` namespace holds the address, the user name and the password or token. In Flux, a Secret of type `kubernetes.io/dockerconfigjson` referenced by `spec.secretRef`, or a cloud provider identity set with `spec.provider`, gives the source controller access. Give these credentials pull permission only.

Trust is a separate question from access. A registry credential proves that the engine may read. It does not prove that the artifact came from your pipeline. Signature verification closes that gap, and Flux does it with `spec.verify` on the `OCIRepository`. Without verification, anyone with push access to the repository can change what the cluster applies.

## A decision record

Write down the decision for each environment. For example, development follows the main branch of Git for speed. Staging follows the semantic version range `1.0.x` of an artifact, so a release needs a tag. Production follows a digest that a person writes into a reviewed file, so a promotion is a one-line change with a reviewer. The three environments use three levels of pinning from the same two stores.

In this part you saw that Argo CD reads OCI Helm charts and OCI manifest artifacts, that the reconciliation after the fetch is unchanged, and how Git and a registry compare. The summary closes the module.

## Common pitfalls

> [!WARNING]
> Do not assume that every Argo CD version reads plain manifest artifacts: the OCI manifest source needs Argo CD 3.1 or later, while Helm charts in OCI have worked for longer. Also do not replace Git by a registry without keeping the history somewhere. A registry cannot answer who changed what and why.
