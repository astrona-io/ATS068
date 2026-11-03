#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" "$WORK/repo"
cd "$WORK/repo"
git -c user.name=platform -c user.email=platform@starfleet.local revert --no-edit HEAD
git push -q origin main
kubectl -n argocd annotate application scout-staging argocd.argoproj.io/refresh=hard --overwrite
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-staging --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-staging --timeout=300s
