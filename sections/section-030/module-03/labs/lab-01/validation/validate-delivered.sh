#!/usr/bin/env bash
# Grades the delivery: both generated Applications are Synced and Healthy and each environment answers with its own message.
set -u
fail() { echo "FAIL: $*"; exit 1; }
for env in staging production; do
  app="scout-$env"; NS="starfleet-$env"
  [[ "$(kubectl -n argocd get application "$app" -o jsonpath='{.status.sync.status}' 2>/dev/null)" == "Synced" ]] || fail "$app is not Synced: $(kubectl -n argocd get application "$app" -o jsonpath='{.status.conditions[*].message}' 2>/dev/null)"
  [[ "$(kubectl -n argocd get application "$app" -o jsonpath='{.status.health.status}' 2>/dev/null)" == "Healthy" ]] || fail "$app is not Healthy"
  body=""
  for i in $(seq 1 10); do
    body=$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "http://scout.$NS/" 2>/dev/null)
    grep -q '"message"' <<<"$body" && break
    sleep 3
  done
  grep -q "\"message\": *\"$env\"" <<<"$body" || fail "request from shuttle to $NS did not return message $env (got: ${body:-nothing})"
done
echo "PASS: both environments are delivered by the ApplicationSet and answer with their own message"
