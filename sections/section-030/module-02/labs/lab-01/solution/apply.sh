#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
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
    name: scout-readonly
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: scout-chart
  namespace: flux-system
spec:
  interval: 5m
  releaseName: scout
  targetNamespace: starfleet-staging
  chart:
    spec:
      chart: ./chart
      reconcileStrategy: Revision
      sourceRef:
        kind: GitRepository
        name: scout
  values:
    replicaCount: 2
    message: from-flux
YAML
kubectl -n flux-system wait gitrepository/scout --for=condition=Ready --timeout=180s
kubectl -n flux-system wait helmrelease/scout-chart --for=condition=Ready --timeout=300s
