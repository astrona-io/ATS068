#!/usr/bin/env bash
# Plumbing: Flux delivers release 1, then a commit with a bad image tag lands on main. No Alert exists, so nobody is told.
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
  retryInterval: 1m
  path: ./overlays/staging
  prune: true
  wait: true
  timeout: 1m
  sourceRef:
    kind: GitRepository
    name: scout
---
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Provider
metadata:
  name: sink
  namespace: flux-system
spec:
  type: generic
  address: http://sink.starfleet.svc/cgi-bin/events
YAML
kubectl -n flux-system wait gitrepository/scout --for=condition=Ready --timeout=300s
kubectl -n flux-system wait kustomization/scout-staging --for=condition=Ready --timeout=300s
kubectl -n starfleet rollout status deploy/sink --timeout=180s

PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" "$WORK/repo"
cd "$WORK/repo"
sed -i.bak 's/newTag: 6.15.0/newTag: 6.99.0/' overlays/staging/kustomization.yaml && rm overlays/staging/kustomization.yaml.bak
git add -A
git -c user.name=platform -c user.email=platform@starfleet.local commit -q -m "Bump scout to 6.99.0"
git push -q origin main
HEAD_SHA="$(git rev-parse HEAD)"

# Wait until Flux has tried the bad commit and failed, so the learner starts from the broken state.
for i in $(seq 1 72); do
  attempted="$(kubectl -n flux-system get kustomization scout-staging -o jsonpath='{.status.lastAttemptedRevision}' 2>/dev/null || true)"
  ready="$(kubectl -n flux-system get kustomization scout-staging -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)"
  if [[ "$attempted" == *"$HEAD_SHA" && "$ready" == "False" ]]; then break; fi
  sleep 5
done
