#!/usr/bin/env bash
# Grades the recovery in the cluster: Argo CD applied the revert and scout runs 6.14.0 again.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-staging"
[[ "$(kubectl -n argocd get application scout-staging -o jsonpath='{.status.sync.status}' 2>/dev/null)" == "Synced" ]] || fail "scout-staging is not Synced"
[[ "$(kubectl -n argocd get application scout-staging -o jsonpath='{.status.health.status}' 2>/dev/null)" == "Healthy" ]] || fail "scout-staging is not Healthy"
image=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}')
[[ "$image" == "ghcr.io/stefanprodan/podinfo:6.14.0" ]] || fail "image is $image, expected ghcr.io/stefanprodan/podinfo:6.14.0"
ready=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.status.readyReplicas}')
[[ "${ready:-0}" -ge 1 ]] || fail "no scout pod is ready"
echo "PASS: scout-staging is Synced and Healthy on 6.14.0"
