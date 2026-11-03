#!/usr/bin/env bash
# Grades the delivered result: 3 replicas, message preview, tracked by the Application.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-preview"
[[ "$(kubectl -n argocd get application scout-preview -o jsonpath='{.status.sync.status}' 2>/dev/null)" == "Synced" ]] || fail "scout-preview is not Synced"
[[ "$(kubectl -n argocd get application scout-preview -o jsonpath='{.status.health.status}' 2>/dev/null)" == "Healthy" ]] || fail "scout-preview is not Healthy"
tracking=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/tracking-id}' 2>/dev/null)
[[ "$tracking" == scout-preview:* ]] || fail "Deployment scout in $NS is not tracked by scout-preview"
replicas=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.spec.replicas}')
[[ "$replicas" == "3" ]] || fail "Deployment scout has $replicas replicas, expected 3"
body=""
for i in $(seq 1 10); do
  body=$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "http://scout.$NS/" 2>/dev/null)
  grep -q '"message"' <<<"$body" && break
  sleep 3
done
grep -q '"message": *"preview"' <<<"$body" || fail "request from shuttle did not return message preview (got: ${body:-nothing})"
echo "PASS: preview overlay delivered with 3 replicas and message preview"
