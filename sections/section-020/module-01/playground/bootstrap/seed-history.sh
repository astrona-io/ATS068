#!/usr/bin/env bash
# Plumbing: create the organisation and the private repository `scout-deploy` in Gitea and push
# a history of two commits. Usage: seed-history.sh <folder> <release|rollback>
#   release : commit 1 deploys podinfo 6.14.0 (message staging) and carries the tag v1.0.0;
#             commit 2 on main deploys 6.15.0 (message staging-v2).
#   rollback: commit 1 deploys podinfo 6.14.0; commit 2 "Release 6.99.0" deploys an image tag
#             that does not exist.
set -euo pipefail
SRC="$1"; MODE="$2"; REPO="scout-deploy"
AUTH="platform:starfleet-gitops"
LOCAL_PORT=$(( 30000 + RANDOM % 20000 ))
kubectl -n gitea port-forward svc/gitea-http "$LOCAL_PORT:3000" >/dev/null 2>&1 &
PF=$!
trap 'kill $PF 2>/dev/null || true; rm -rf "${WORK:-}"' EXIT
API="http://127.0.0.1:$LOCAL_PORT/api/v1"
for i in $(seq 1 30); do curl -fs "$API/version" >/dev/null 2>&1 && break; sleep 1; done
curl -fs -u "$AUTH" -X POST -H 'Content-Type: application/json' "$API/orgs" \
  -d '{"username":"starfleet","visibility":"public"}' >/dev/null || true
curl -fs -u "$AUTH" -X POST -H 'Content-Type: application/json' "$API/orgs/starfleet/repos" \
  -d "{\"name\":\"$REPO\",\"private\":true,\"default_branch\":\"main\"}" >/dev/null || true
WORK="$(mktemp -d)"
cp -R "$SRC/." "$WORK/"
cd "$WORK"
git init -q -b main
GIT="git -c user.name=platform -c user.email=platform@starfleet.local"
sed -i.bak 's/newTag: 6.15.0/newTag: 6.14.0/' overlays/staging/kustomization.yaml && rm overlays/staging/kustomization.yaml.bak
$GIT add -A
$GIT commit -q -m "Release 1.0.0"
if [ "$MODE" = release ]; then
  git tag v1.0.0
  sed -i.bak 's/newTag: 6.14.0/newTag: 6.15.0/' overlays/staging/kustomization.yaml && rm overlays/staging/kustomization.yaml.bak
  sed -i.bak 's/value: staging$/value: staging-v2/' overlays/staging/message.yaml && rm overlays/staging/message.yaml.bak
  $GIT commit -q -am "Release 1.1.0"
else
  sed -i.bak 's/newTag: 6.14.0/newTag: 6.99.0/' overlays/staging/kustomization.yaml && rm overlays/staging/kustomization.yaml.bak
  $GIT commit -q -am "Release 6.99.0"
fi
git push -q "http://$AUTH@127.0.0.1:$LOCAL_PORT/starfleet/$REPO.git" main --force
[ "$MODE" = release ] && git push -q "http://$AUTH@127.0.0.1:$LOCAL_PORT/starfleet/$REPO.git" v1.0.0 --force
echo "[lab] Seeded starfleet/$REPO ($MODE)"
