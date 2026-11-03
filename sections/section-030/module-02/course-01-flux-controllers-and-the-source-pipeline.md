---
draft: true
exam_objectives:
- Reconciliation Engines (ArgoCD, Flux, and alternatives)
---
# Flux Controllers And The Source Pipeline

Flux splits the reconciliation loop into controllers. Each controller watches its own kind of object and reports in the status of that object. This part names the controllers, explains how a Git repository becomes an artifact, and shows how to read the revision and the conditions.

## The controllers

The source controller fetches content. Its objects are `GitRepository`, `HelmRepository`, `OCIRepository`, `Bucket` and `HelmChart`. For each object it fetches the content, packs it as an archive and serves it inside the cluster. The archive is the artifact.

The kustomize controller owns the `Kustomization` object. It reads an artifact, builds the path with Kustomize, applies the result to the cluster and keeps an inventory of what it applied. The name Kustomization here is a Flux object, and it is not the same as a `kustomization.yaml` file, although it can build one.

The Helm controller owns the `HelmRelease` object. It takes a chart from a source and runs Helm install, upgrade, test and rollback with the Helm library. The notification controller sends and receives events. The image controllers, which update image tags in Git, are not used in this module and are scaled to zero in the playground.

```mermaid
flowchart LR
  G["Git remote"] --> SC["source-controller"]
  SC --> A["artifact"]
  A --> KC["kustomize-controller"]
  A --> HC["helm-controller"]
  KC --> K["cluster objects"]
  HC --> K
```

The diagram shows that only the source controller talks to the Git remote. The other two read its artifact and change the cluster.

## The GitRepository object

A GitRepository names a URL, a branch, tag, semantic version or commit under `spec.ref`, a `spec.interval` and optionally a `spec.secretRef` with credentials. At each interval the source controller checks the remote. If the commit changed, it builds a new artifact. The status shows the result in `status.artifact`, with the URL of the archive, a digest and the `revision`.

The revision has the form `main@sha1:` followed by the commit ID. It names the branch, the hash type and the commit, so one value says what was asked for and what was received. The digest in the artifact is a hash of the archive itself.

A GitRepository does not apply anything. It makes content available. Several Kustomizations and HelmReleases can use the same source, so one fetch serves many deliveries.

## Conditions

Every Flux object has `status.conditions`. The condition `Ready` is `True` when the last reconciliation succeeded and `False` when it failed, and its message says why. During work the condition `Reconciling` is `True`. The condition `Stalled` is `True` when the controller gave up because the configuration cannot work without a change.

The field `status.observedGeneration` says which version of the spec the controller has seen. If it is lower than `metadata.generation`, the controller has not processed your latest edit yet. Waiting for `Ready` right after an edit can be misleading if the old status is still there, so compare the generations.

## Try it: fetch a repository

Use the playground to create a source and read its artifact. The Secret `scout-readonly` holds a user with read access to the repository.

<!-- astrona:playground:renew -->

Save this as `gitrepository-scout.yaml`:

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

Apply it and read the status:

```sh
kubectl apply -f gitrepository-scout.yaml
kubectl -n flux-system wait gitrepository/scout --for=condition=Ready --timeout=120s
kubectl -n flux-system get gitrepository scout -o jsonpath='{.status.artifact.revision}{"\n"}'
```

The printed revision starts with `main@sha1:`. Compare the commit with the one on the remote:

```sh
git ls-remote http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git refs/heads/main
```

The two commit IDs are equal. Now change the secret reference to a name that does not exist, apply the file, and read the condition:

```sh
kubectl -n flux-system get gitrepository scout -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}{"\n"}'
```

The message names the missing Secret. Restore the name and the source becomes `Ready` again. Reading the message first is the fastest way to find a source problem.

## Forcing a reconcile

Flux works on intervals, but a person can ask for an early run. The annotation `reconcile.fluxcd.io/requestedAt` with any new value makes the controller reconcile that object at once. The `flux reconcile` command writes this annotation for you.

```sh
kubectl -n flux-system annotate gitrepository/scout --overwrite reconcile.fluxcd.io/requestedAt="$(date +%s)"
```

The annotation only starts a run. It does not skip the checks, and it does not force an apply of unchanged content.

## What the source does not do

The source controller does not render Helm values, does not apply manifests and does not decide when to deploy. A Git change that reaches the artifact is not yet in the cluster. The objects that read the artifact must reconcile as well, and they do it on their own interval, or at once when a new revision arrives.

## Common pitfalls

> [!WARNING]
> A Ready source only means that the content was fetched. It does not mean that anything was delivered. Read the status of the Kustomization or HelmRelease too, and compare `observedGeneration` with `generation` after an edit so you do not read an old status.
