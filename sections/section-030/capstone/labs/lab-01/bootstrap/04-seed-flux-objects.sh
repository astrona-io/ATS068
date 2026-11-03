#!/usr/bin/env bash
# Plumbing: build the starting state. Flux delivers release 1, then Git moves on to release 2, then both pipelines are paused.
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
  timeout: 3m
  sourceRef:
    kind: GitRepository
    name: scout
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: scout-production
  namespace: flux-system
spec:
  interval: 5m
  releaseName: scout
  targetNamespace: starfleet-production
  install:
    createNamespace: true
  chart:
    spec:
      chart: ./chart
      reconcileStrategy: Revision
      sourceRef:
        kind: GitRepository
        name: scout
YAML
kubectl -n flux-system wait kustomization/scout-staging --for=condition=Ready --timeout=300s
kubectl -n flux-system wait helmrelease/scout-production --for=condition=Ready --timeout=300s

PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" "$WORK/repo"
cd "$WORK/repo"
sed -i.bak 's/value: staging$/value: staging-v2/' overlays/staging/message.yaml && rm overlays/staging/message.yaml.bak
sed -i.bak 's/^message: chart$/message: chart-v2/' chart/values.yaml && rm chart/values.yaml.bak
git add -A
git -c user.name=platform -c user.email=platform@starfleet.local commit -q -m "Release 2"
git push -q origin main

kubectl -n flux-system patch kustomization scout-staging --type merge -p '{"spec":{"suspend":true}}'
kubectl -n flux-system patch helmrelease scout-production --type merge -p '{"spec":{"suspend":true}}'
