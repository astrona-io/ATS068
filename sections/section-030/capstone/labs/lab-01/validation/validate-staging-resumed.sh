#!/usr/bin/env bash
# Grades the Kustomization: resumed, unchanged definition, applied the newest commit of main.
set -u
fail() { echo "FAIL: $*"; exit 1; }
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!; disown
trap 'kill $PF 2>/dev/null || true' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
k() { kubectl -n flux-system get kustomization scout-staging -o jsonpath="$1" 2>/dev/null; }
kubectl -n flux-system get kustomization scout-staging >/dev/null 2>&1 || fail "no Kustomization scout-staging; do not delete it"
[[ "$(k '{.spec.suspend}')" != "true" ]] || fail "Kustomization scout-staging is still suspended"
[[ "$(k '{.spec.path}')" == "./overlays/staging" && "$(k '{.spec.prune}')" == "true" ]] || fail "the path and prune: true must stay as they are"
[[ "$(k '{.status.conditions[?(@.type=="Ready")].status}')" == "True" ]] || fail "Kustomization scout-staging is not Ready"
head=$(git ls-remote "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" refs/heads/main | cut -f1)
[[ -n "$head" ]] || fail "cannot read main"
[[ "$(k '{.status.lastAppliedRevision}')" == *"$head" ]] || fail "Flux applied '$(k '{.status.lastAppliedRevision}')', main is at $head; reconcile the source and the Kustomization"
echo "PASS: scout-staging is resumed and applied the head of main ($head)"
