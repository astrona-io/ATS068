# Solution

## Step 1: Find the cause

Read the suspend field and the conditions of the two deliveries:

```sh
kubectl -n flux-system get kustomization scout-staging -o jsonpath='{.spec.suspend}{" "}{.status.lastAppliedRevision}{"\n"}'
kubectl -n flux-system get helmrelease scout-production -o jsonpath='{.spec.suspend}{"\n"}'
kubectl -n flux-system get gitrepository scout -o jsonpath='{.status.artifact.revision}{"\n"}'
```

The source is `Ready` and holds the newest revision. Both deliveries have `spec.suspend` set to `true`, and the last applied revision of the Kustomization is older than the source. A suspended object keeps its old `Ready` status, so the conditions look healthy.

## Step 2: Resume both

```sh
kubectl -n flux-system patch kustomization scout-staging --type merge -p '{"spec":{"suspend":false}}'
kubectl -n flux-system patch helmrelease scout-production --type merge -p '{"spec":{"suspend":false}}'
```

The `flux resume` command writes the same field.

## Step 3: Ask for an early reconcile

Flux works at the interval, which is five minutes here. Ask for a run now:

```sh
STAMP="$(date +%s)"
kubectl -n flux-system annotate gitrepository/scout --overwrite reconcile.fluxcd.io/requestedAt="$STAMP"
kubectl -n flux-system annotate kustomization/scout-staging --overwrite reconcile.fluxcd.io/requestedAt="$STAMP"
kubectl -n flux-system annotate helmrelease/scout-production --overwrite reconcile.fluxcd.io/requestedAt="$STAMP"
kubectl -n flux-system wait kustomization/scout-staging --for=condition=Ready --timeout=240s
kubectl -n flux-system wait helmrelease/scout-production --for=condition=Ready --timeout=300s
```

The Kustomization applies the new overlay. The HelmRelease uses `reconcileStrategy: Revision`, so the new Git revision produces a new chart, and the Helm controller upgrades the release.

Run `astrona submit`. All three checks should pass. If `delivered` fails right after the waits, repeat the request from `shuttle` after a short time: the pods must finish their rollout first.
