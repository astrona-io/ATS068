#!/usr/bin/env bash
# Grades what is delivered: Synced, Healthy, objects tracked by the Application, answers from scout.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-staging"
[[ "$(kubectl -n argocd get application scout -o jsonpath='{.status.sync.status}' 2>/dev/null)" == "Synced" ]] || fail "scout is not Synced; read the conditions and the operation state of the Application"
[[ "$(kubectl -n argocd get application scout -o jsonpath='{.status.health.status}' 2>/dev/null)" == "Healthy" ]] || fail "scout is not Healthy"
tracking=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/tracking-id}' 2>/dev/null)
[[ "$tracking" == scout:* ]] || fail "Deployment scout in $NS is not tracked by the Application scout"
body=""
for i in $(seq 1 10); do
  body=$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "http://scout.$NS/" 2>/dev/null)
  grep -q '"message"' <<<"$body" && break
  sleep 3
done
grep -q '"message": *"staging"' <<<"$body" || fail "request from shuttle did not return message staging (got: ${body:-nothing})"
echo "PASS: scout is Synced, Healthy and answers with message staging"
