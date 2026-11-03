#!/usr/bin/env bash
# Grades the result: Ready, two replicas, the message from the values, and a Helm release record.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-staging"
[[ "$(kubectl -n flux-system get helmrelease scout-chart -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)" == "True" ]] || fail "HelmRelease scout-chart is not Ready: $(kubectl -n flux-system get helmrelease scout-chart -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}' 2>/dev/null)"
ready=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
[[ "${ready:-0}" == "2" ]] || fail "Deployment scout has ${ready:-0} ready replicas, expected 2"
body=""
for i in $(seq 1 10); do
  body=$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "http://scout.$NS/" 2>/dev/null)
  grep -q '"message"' <<<"$body" && break
  sleep 3
done
grep -q '"message": *"from-flux"' <<<"$body" || fail "request from shuttle did not return message from-flux (got: ${body:-nothing})"
count=$(kubectl get secret -A -l owner=helm,name=scout --no-headers 2>/dev/null | wc -l | tr -d ' ')
[[ "$count" -ge 1 ]] || fail "no Helm release record found; Flux helm-controller should have installed a Helm release named scout"
echo "PASS: scout runs 2 replicas with message from-flux, installed as a Helm release"
