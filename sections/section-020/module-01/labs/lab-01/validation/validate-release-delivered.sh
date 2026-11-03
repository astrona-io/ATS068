#!/usr/bin/env bash
# Grades what is delivered: release 1.0.0 (podinfo 6.14.0, message staging), not the newer main.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-staging"
kubectl -n argocd get application scout-release >/dev/null 2>&1 || fail "no Application scout-release"
[[ "$(kubectl -n argocd get application scout-release -o jsonpath='{.status.sync.status}')" == "Synced" ]] || fail "scout-release is not Synced"
[[ "$(kubectl -n argocd get application scout-release -o jsonpath='{.status.health.status}')" == "Healthy" ]] || fail "scout-release is not Healthy"
tracking=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/tracking-id}' 2>/dev/null)
[[ "$tracking" == scout-release:* ]] || fail "Deployment scout in $NS is not tracked by scout-release"
image=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}')
[[ "$image" == "ghcr.io/stefanprodan/podinfo:6.14.0" ]] || fail "image is $image, expected ghcr.io/stefanprodan/podinfo:6.14.0 (release 1.0.0)"
body=""
for i in $(seq 1 10); do
  body=$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "http://scout.$NS/" 2>/dev/null)
  grep -q '"version"' <<<"$body" && break
  sleep 3
done
grep -q '"version": *"6.14.0"' <<<"$body" || fail "request from shuttle did not return version 6.14.0 (got: ${body:-nothing})"
grep -q '"message": *"staging"' <<<"$body" || fail "request from shuttle did not return message staging"
echo "PASS: release 1.0.0 is delivered: version 6.14.0 and message staging"
