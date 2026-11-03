#!/usr/bin/env bash
# Plumbing: Flux delivers the staging overlay. The GitRepository uses a Secret that can push, so that image automation can commit.
set -euo pipefail
kubectl apply -f - <<'YAML'
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
    name: scout-write
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: scout-staging
  namespace: flux-system
spec:
  interval: 5m
  path: ./overlays/staging
  prune: true
  wait: true
  timeout: 2m
  sourceRef:
    kind: GitRepository
    name: scout
YAML
kubectl -n flux-system wait gitrepository/scout --for=condition=Ready --timeout=300s
kubectl -n flux-system wait kustomization/scout-staging --for=condition=Ready --timeout=300s
kubectl -n starfleet rollout status deploy/sink --timeout=180s
