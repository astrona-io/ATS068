#!/usr/bin/env bash
# Grades that the fix did not change how the Application follows Git.
set -u
fail() { echo "FAIL: $*"; exit 1; }
get() { kubectl -n argocd get application scout-staging -o jsonpath="$1" 2>/dev/null; }
[[ "$(get '{.spec.source.targetRevision}')" == "main" ]] || fail "the Application must keep following main (targetRevision is '$(get '{.spec.source.targetRevision}')')"
[[ "$(get '{.spec.syncPolicy.automated.prune}')" == "true" && "$(get '{.spec.syncPolicy.automated.selfHeal}')" == "true" ]] || fail "automated prune and self-heal must stay on"
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!; disown
trap 'kill $PF 2>/dev/null || true' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
head=$(git ls-remote "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" refs/heads/main | cut -f1)
[[ "$(get '{.status.sync.revision}')" == "$head" ]] || fail "the Application synced '$(get '{.status.sync.revision}')', but main is at $head"
echo "PASS: the Application still follows main with automated prune and self-heal, at the head commit"
