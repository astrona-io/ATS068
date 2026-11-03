#!/usr/bin/env bash
# Grades the history: the bad release is still in the history of main and a revert commit is on top.
set -u
fail() { echo "FAIL: $*"; exit 1; }
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!; disown
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
API="http://127.0.0.1:$PORT/api/v1"
for i in $(seq 1 30); do curl -fs "$API/version" >/dev/null 2>&1 && break; sleep 1; done
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" "$WORK/repo" 2>/dev/null || fail "cannot clone the repository"
cd "$WORK/repo" || exit 1
bad=$(git log --format=%H --grep='^Release 6.99.0$' main | head -1)
[[ -n "$bad" ]] || fail "the commit 'Release 6.99.0' is not in the history of main; do not rewrite history, add a revert commit"
subject=$(git log -1 --format=%s main)
[[ "$subject" == Revert* ]] || fail "the newest commit on main is '$subject'; expected a revert commit (its subject starts with Revert)"
tag=$(sed -n 's/^ *newTag: *//p' <(git show main:overlays/staging/kustomization.yaml) | head -1)
[[ "$tag" == "6.14.0" ]] || fail "overlays/staging on main uses newTag '$tag', expected 6.14.0"
echo "PASS: the bad release is kept in history and a revert commit restores 6.14.0"
