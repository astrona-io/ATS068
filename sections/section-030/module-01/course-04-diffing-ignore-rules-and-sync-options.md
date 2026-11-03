---
draft: true
exam_objectives:
- Reconciliation Engines (ArgoCD, Flux, and alternatives)
---
# Diffing, Ignore Rules And Sync Options

Argo CD decides that an Application is out of sync by comparing the rendered manifests with the live objects. That comparison is not always as simple as it sounds. Controllers add fields to objects, defaults fill in values, and some changes should never be reverted. This part explains how the diff works, how to stop false differences, and which sync options change the way objects are applied.

## What the diff compares

The application controller takes the manifests from the repo-server and the live objects from its cache of the cluster. It normalizes both, removes fields that Kubernetes fills in on its own, such as `status` and `metadata.resourceVersion`, and compares the rest. Any remaining difference makes the object `OutOfSync`. The diff in the UI and from `argocd app diff` shows these differences.

A false difference appears when something else changes a field that Git also sets. A horizontal pod autoscaler changes `spec.replicas` of a Deployment. An admission webhook injects a sidecar. A controller adds an annotation. Each such change makes the Application `OutOfSync`, and with self-heal enabled, Argo CD would revert it on every pass.

## ignoreDifferences

The `ignoreDifferences` field of an Application tells the diff to skip certain fields.

```yaml
spec:
  ignoreDifferences:
    - group: apps
      kind: Deployment
      name: scout
      jsonPointers:
        - /spec/replicas
```

An entry selects objects by `group`, `kind`, `name` and `namespace`, and names the fields with `jsonPointers`, with `jqPathExpressions` for list elements, or with `managedFieldsManagers` to ignore everything set by a named field manager. The same rules can be set for the whole installation in `argocd-cm` under `resource.customizations.ignoreDifferences.<group_kind>`.

Ignored fields are left out of the comparison, but they are still applied during a sync, unless the sync option `RespectIgnoreDifferences=true` is set. With that option, an ignored field is also kept at its live value when Argo CD applies the object. Without it, a sync can still overwrite the field with the Git value.

## Server-side apply

By default Argo CD applies objects with a client-side apply, which stores the last applied configuration in an annotation. The sync option `ServerSideApply=true` uses server-side apply instead. The API server then tracks ownership of each field, so two tools can manage different fields of one object without conflict. It also avoids the size limit on the last-applied annotation, which large custom resource definitions hit. The cost is that field ownership conflicts become visible and must be resolved with `--force-conflicts` behaviour, which Argo CD applies.

## Other sync options

Sync options are listed in `spec.syncPolicy.syncOptions` for the Application, or as an annotation on a single object.

- `CreateNamespace=true` creates the destination namespace if it is missing.
- `Prune=false` on an object stops Argo CD from deleting it even when it leaves Git. `PruneLast=true` deletes pruned objects after the other objects are healthy.
- `Replace=true` uses `kubectl replace` instead of apply. It overwrites the object and can lose fields set by other tools. Use it only for objects that apply cannot handle.
- `Validate=false` skips the schema validation of the API server.
- `ApplyOutOfSyncOnly=true` applies only the objects that are out of sync, instead of every object in the Application. This lowers the load for Applications with thousands of objects.
- `FailOnSharedResource=true` fails the sync if an object is already managed by another Application.

## Hooks

A hook is an object that runs at a point of the sync. The annotation `argocd.argoproj.io/hook` takes `PreSync`, `Sync`, `PostSync`, `SyncFail` or `Skip`. A Job with the `PreSync` hook runs before the other objects, which fits a database migration. The annotation `argocd.argoproj.io/hook-delete-policy` takes `HookSucceeded`, `HookFailed` or `BeforeHookCreation`, and decides when the hook object is removed. If a PreSync hook fails, the sync stops and the other objects are not applied.

## Try it: ignore a replica count

Run these commands in the playground after an Application delivers a Deployment:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet-staging scale deploy/scout --replicas=3
kubectl -n argocd get application -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.sync.status}{"\n"}{end}'
```

The Application becomes `OutOfSync` because the live replica count differs from Git. If self-heal is on, Argo CD sets it back. Add the `ignoreDifferences` entry above to the Application and repeat. The Application stays `Synced`, and the replica count stays at 3.

## Common mistakes

- Ignoring a field without `RespectIgnoreDifferences` and then wondering why a sync resets it.
- Using `Replace=true` as a general fix for apply errors.
- Writing a JSON pointer with dots instead of slashes.
- Putting a Job without a hook delete policy in a PreSync hook, so the next sync fails on a name that already exists.

## Check yourself

- Which fields does the diff remove before it compares?
- When is `ServerSideApply=true` the better choice?
- What happens to the sync when a PreSync hook fails?
