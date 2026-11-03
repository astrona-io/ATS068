#!/usr/bin/env bash
# Grades what Argo CD delivered from the directory source.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-staging"
kubectl -n argocd get application scout-plain >/dev/null 2>&1 || fail "no Application scout-plain"
[[ "$(kubectl -n argocd get application scout-plain -o jsonpath='{.status.sync.status}')" == "Synced" ]] || fail "scout-plain is not Synced"
[[ "$(kubectl -n argocd get application scout-plain -o jsonpath='{.status.health.status}')" == "Healthy" ]] || fail "scout-plain is not Healthy"
kubectl -n "$NS" get deploy scout >/dev/null 2>&1 || fail "Deployment scout does not exist in $NS"
kubectl -n "$NS" get configmap scout-notes >/dev/null 2>&1 || fail "ConfigMap scout-notes (in plain/extra) does not exist in $NS: is recurse on?"
if kubectl -n "$NS" get configmap scout-draft >/dev/null 2>&1; then fail "ConfigMap scout-draft exists in $NS: the drafts folder must be excluded"; fi
echo "PASS: scout-plain delivered scout and scout-notes, and left out scout-draft"
