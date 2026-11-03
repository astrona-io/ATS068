#!/usr/bin/env bash
# Grades what Argo CD evaluated from the Jsonnet program and delivered.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-production"
kubectl -n argocd get application scout-jsonnet >/dev/null 2>&1 || fail "no Application scout-jsonnet"
[[ "$(kubectl -n argocd get application scout-jsonnet -o jsonpath='{.status.sync.status}')" == "Synced" ]] || fail "scout-jsonnet is not Synced"
[[ "$(kubectl -n argocd get application scout-jsonnet -o jsonpath='{.status.health.status}')" == "Healthy" ]] || fail "scout-jsonnet is not Healthy"
replicas=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.spec.replicas}' 2>/dev/null)
[[ "$replicas" == "2" ]] || fail "Deployment scout has ${replicas:-no} replicas, expected 2 from the external variable"
body=""
for i in $(seq 1 10); do
  body=$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "http://scout.$NS/" 2>/dev/null)
  grep -q '"message"' <<<"$body" && break
  sleep 3
done
grep -q '"message": *"from-jsonnet"' <<<"$body" || fail "request from shuttle did not return message from-jsonnet (got: ${body:-nothing})"
echo "PASS: Jsonnet program evaluated with 2 replicas and message from-jsonnet"
