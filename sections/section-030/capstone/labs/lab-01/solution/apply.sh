#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
kubectl -n flux-system patch kustomization scout-staging --type merge -p '{"spec":{"suspend":false}}'
kubectl -n flux-system patch helmrelease scout-production --type merge -p '{"spec":{"suspend":false}}'
STAMP="$(date +%s)"
kubectl -n flux-system annotate gitrepository/scout --overwrite "reconcile.fluxcd.io/requestedAt=$STAMP"
kubectl -n flux-system wait gitrepository/scout --for=condition=Ready --timeout=120s
kubectl -n flux-system annotate kustomization/scout-staging --overwrite "reconcile.fluxcd.io/requestedAt=$STAMP"
kubectl -n flux-system annotate helmrelease/scout-production --overwrite "reconcile.fluxcd.io/requestedAt=$STAMP"
kubectl -n flux-system wait kustomization/scout-staging --for=condition=Ready --timeout=240s
kubectl -n flux-system wait helmrelease/scout-production --for=condition=Ready --timeout=300s
