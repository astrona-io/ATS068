#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
kubectl apply -f - <<'YAML'
apiVersion: source.toolkit.fluxcd.io/v1
kind: OCIRepository
metadata:
  name: scout-oci
  namespace: flux-system
spec:
  interval: 1m
  url: oci://registry.registry.svc:5000/scout-manifests
  insecure: true
  ref:
    semver: 1.0.x
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: scout-oci
  namespace: flux-system
spec:
  interval: 1m
  path: ./
  prune: true
  targetNamespace: starfleet-staging
  sourceRef:
    kind: OCIRepository
    name: scout-oci
YAML
kubectl -n flux-system wait --for=condition=Ready ocirepository/scout-oci --timeout=180s
kubectl -n flux-system wait --for=condition=Ready kustomization/scout-oci --timeout=240s
kubectl -n starfleet-staging rollout status deploy/scout --timeout=180s
