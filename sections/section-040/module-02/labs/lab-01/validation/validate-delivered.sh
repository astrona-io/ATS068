#!/usr/bin/env bash
# Grades the whole path: the automation commits the new tag to Git and Flux rolls it out.
set -u
fail() { echo "FAIL: $*"; exit 1; }
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!; disown
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
tag="$(kubectl -n flux-system get imagepolicy scout -o jsonpath='{.status.latestRef.tag}' 2>/dev/null)"
[[ "$tag" == 6.15.* ]] || fail "the ImagePolicy has not selected a 6.15 tag"
ok=""
for i in $(seq 1 48); do
  rm -rf "$WORK/repo"
  git clone -q "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" "$WORK/repo" 2>/dev/null || { sleep 5; continue; }
  grep -q "newTag: $tag" "$WORK/repo/overlays/staging/kustomization.yaml" && { ok=1; break; }
  sleep 5
done
[[ -n "$ok" ]] || fail "overlays/staging/kustomization.yaml in Git does not contain newTag: $tag; the automation has not pushed"
author="$(git -C "$WORK/repo" log -1 --format=%an -- overlays/staging/kustomization.yaml)"
[[ "$author" == "fluxbot" ]] || fail "the last commit of the file was made by '$author', expected fluxbot"
grep -q '\$imagepolicy' "$WORK/repo/overlays/staging/kustomization.yaml" || fail "the marker comment was removed from the file"
ok=""
for i in $(seq 1 48); do
  img="$(kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)"
  [[ "$img" == "ghcr.io/stefanprodan/podinfo:$tag" ]] && { ok=1; break; }
  sleep 5
done
[[ -n "$ok" ]] || fail "the Deployment scout runs '$img', expected ghcr.io/stefanprodan/podinfo:$tag"
kubectl -n starfleet-staging rollout status deploy/scout --timeout=120s >/dev/null 2>&1 || fail "the Deployment scout did not become ready"
echo "PASS: the automation committed $tag as fluxbot and Flux rolled it out"
