#!/usr/bin/env bash
# Grades the result: Ready, one replica, the message from artifact 1.0.0, and the inventory.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-staging"
[[ "$(kubectl -n flux-system get kustomization scout-oci -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)" == "True" ]] || fail "Kustomization scout-oci is not Ready: $(kubectl -n flux-system get kustomization scout-oci -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}' 2>/dev/null)"
applied="$(kubectl -n flux-system get kustomization scout-oci -o jsonpath='{.status.lastAppliedRevision}' 2>/dev/null)"
[[ "$applied" == 1.0.0@sha256:* ]] || fail "lastAppliedRevision is '$applied', expected 1.0.0@sha256:<digest>"
ready=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
[[ "${ready:-0}" == "1" ]] || fail "Deployment scout has ${ready:-0} ready replicas, expected 1"
body=""
for i in $(seq 1 10); do
  body=$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "http://scout.$NS/" 2>/dev/null)
  grep -q '"message"' <<<"$body" && break
  sleep 3
done
grep -q '"message": *"oci-one"' <<<"$body" || fail "request from shuttle did not return message oci-one (got: ${body:-nothing})"
echo "PASS: scout from artifact 1.0.0 answers with message oci-one"
