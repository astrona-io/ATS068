#!/usr/bin/env bash
# Grades that the pin matters: main is ahead and the Application did not follow it.
set -u
fail() { echo "FAIL: $*"; exit 1; }
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!; disown
trap 'kill $PF 2>/dev/null || true' EXIT
API="http://127.0.0.1:$PORT/api/v1"
for i in $(seq 1 30); do curl -fs "$API/version" >/dev/null 2>&1 && break; sleep 1; done
URL="http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git"
tag_commit=$(git ls-remote "$URL" refs/tags/v1.0.0 | cut -f1)
main_head=$(git ls-remote "$URL" refs/heads/main | cut -f1)
[[ -n "$tag_commit" && -n "$main_head" ]] || fail "cannot read the tag or main"
[[ "$tag_commit" != "$main_head" ]] || fail "main and v1.0.0 point to the same commit; do not move the tag or rewrite main"
synced=$(kubectl -n argocd get application scout-release -o jsonpath='{.status.sync.revision}' 2>/dev/null)
[[ "$synced" == "$tag_commit" ]] || fail "the Application synced revision '$synced', expected the tag commit $tag_commit"
echo "PASS: main is ahead of v1.0.0 and the Application still runs v1.0.0"
