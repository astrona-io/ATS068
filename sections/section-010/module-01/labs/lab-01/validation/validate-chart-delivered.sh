#!/usr/bin/env bash
# Grades what Argo CD rendered from the chart and delivered.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-staging"
kubectl -n argocd get application scout-chart >/dev/null 2>&1 || fail "no Application scout-chart"
[[ "$(kubectl -n argocd get application scout-chart -o jsonpath='{.status.sync.status}')" == "Synced" ]] || fail "scout-chart is not Synced"
[[ "$(kubectl -n argocd get application scout-chart -o jsonpath='{.status.health.status}')" == "Healthy" ]] || fail "scout-chart is not Healthy"
tracking=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/tracking-id}' 2>/dev/null)
[[ "$tracking" == scout-chart:* ]] || fail "Deployment scout in $NS is not tracked by scout-chart"
replicas=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.spec.replicas}')
[[ "$replicas" == "2" ]] || fail "Deployment scout has $replicas replicas, expected 2 from the Helm values"
inst=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.metadata.labels.app\.kubernetes\.io/instance}')
[[ "$inst" == "scout" ]] || fail "label app.kubernetes.io/instance is '$inst', expected the release name scout"
body=""
for i in $(seq 1 10); do
  body=$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "http://scout.$NS/" 2>/dev/null)
  grep -q '"message"' <<<"$body" && break
  sleep 3
done
grep -q '"message": *"from-chart"' <<<"$body" || fail "request from shuttle did not return message from-chart (got: ${body:-nothing})"
echo "PASS: chart rendered with release name scout, 2 replicas and message from-chart"
