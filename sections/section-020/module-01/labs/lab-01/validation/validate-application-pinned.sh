#!/usr/bin/env bash
# Grades the definition: the Application follows the commit ID that the tag v1.0.0 points to.
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
[[ "$tag_commit" =~ ^[0-9a-f]{40}$ ]] || fail "cannot read the commit of the tag v1.0.0"
kubectl -n argocd get application scout-release >/dev/null 2>&1 || fail "no Application scout-release in the namespace argocd"
get() { kubectl -n argocd get application scout-release -o jsonpath="$1"; }
[[ "$(get '{.spec.source.repoURL}')" == "http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git" ]] || fail "wrong repoURL"
[[ "$(get '{.spec.source.path}')" == "overlays/staging" ]] || fail "path is '$(get '{.spec.source.path}')', expected overlays/staging"
[[ "$(get '{.spec.destination.namespace}')" == "starfleet-staging" ]] || fail "destination namespace is '$(get '{.spec.destination.namespace}')', expected starfleet-staging"
rev=$(get '{.spec.source.targetRevision}')
[[ "$rev" =~ ^[0-9a-f]{40}$ ]] || fail "targetRevision is '$rev'; use the full 40-character commit ID, not a branch or a tag name"
[[ "$rev" == "$tag_commit" ]] || fail "targetRevision $rev is not the commit of the tag v1.0.0 ($tag_commit)"
echo "PASS: the Application is pinned to the commit ID of the tag v1.0.0"
