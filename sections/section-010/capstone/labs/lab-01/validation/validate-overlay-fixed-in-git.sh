#!/usr/bin/env bash
# Grades the fix in Git: the patch targets scout, and the base was not changed.
set -u
fail() { echo "FAIL: $*"; exit 1; }
GIT_PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$GIT_PORT:3000" >/dev/null 2>&1 &
PF=$!; disown
trap 'kill $PF 2>/dev/null || true' EXIT
API="http://127.0.0.1:$GIT_PORT/api/v1"
for i in $(seq 1 30); do curl -fs "$API/version" >/dev/null 2>&1 && break; sleep 1; done
raw() { curl -fs -u platform:starfleet-gitops "$API/repos/starfleet/scout-deploy/raw/$1?ref=main"; }
patch=$(raw overlays/preview/message.yaml) || fail "cannot read overlays/preview/message.yaml on branch main"
name=$(sed -n 's/^  name: *//p' <<<"$patch" | head -1)
[[ "$name" == "scout" ]] || fail "the patch in overlays/preview/message.yaml targets '$name', expected scout"
grep -q 'value: preview' <<<"$patch" || fail "the patch no longer sets the message preview"
sum=$(raw base/deployment.yaml | shasum -a 256 | cut -d' ' -f1)
[[ "$sum" == "643f6007a1969f2db08f30ad9a2d639ae2d24035042fecc59a6604df1e95a69d" ]] || fail "base/deployment.yaml was changed; fix the overlay, not the base"
echo "PASS: the overlay patch targets scout and the base is unchanged"
