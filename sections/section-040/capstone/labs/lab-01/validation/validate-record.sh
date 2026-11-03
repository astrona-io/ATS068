#!/usr/bin/env bash
# Grades the evidence record: the failed commit and the failed image.
set -u
fail() { echo "FAIL: $*"; exit 1; }
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!; disown
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" "$WORK/repo" || fail "cannot clone the repository"
bad="$(git -C "$WORK/repo" log --format=%H --grep='Bump scout to 6.99.0' -n 1)"
[[ -n "$bad" ]] || fail "the commit 'Bump scout to 6.99.0' is not in the history; do not rewrite history"
cm() { kubectl -n starfleet get configmap delivery-record -o jsonpath="$1" 2>/dev/null; }
kubectl -n starfleet get configmap delivery-record >/dev/null 2>&1 || fail "no ConfigMap delivery-record in the namespace starfleet"
rev="$(cm '{.data.failed-revision}')"
rev="${rev#main@sha1:}"
[[ "$rev" == "$bad" ]] || fail "failed-revision is '$rev', expected the commit that Flux could not apply ($bad)"
[[ "$(cm '{.data.image}')" == "ghcr.io/stefanprodan/podinfo:6.99.0" ]] || fail "image is '$(cm '{.data.image}')', expected the full image reference that failed to start"
echo "PASS: delivery-record names the failed commit and image"
