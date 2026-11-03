#!/usr/bin/env bash
# Grades what Argo CD built from the overlay and delivered.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-production"
kubectl -n argocd get application scout-overlay >/dev/null 2>&1 || fail "no Application scout-overlay"
[[ "$(kubectl -n argocd get application scout-overlay -o jsonpath='{.status.sync.status}')" == "Synced" ]] || fail "scout-overlay is not Synced"
[[ "$(kubectl -n argocd get application scout-overlay -o jsonpath='{.status.health.status}')" == "Healthy" ]] || fail "scout-overlay is not Healthy"
tracking=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.metadata.annotations.argocd\.argoproj\.io/tracking-id}' 2>/dev/null)
[[ "$tracking" == scout-overlay:* ]] || fail "Deployment scout in $NS is not tracked by scout-overlay"
image=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}')
[[ "$image" == "ghcr.io/stefanprodan/podinfo:6.14.0" ]] || fail "image is $image, expected ghcr.io/stefanprodan/podinfo:6.14.0 (the overlay in Git says 6.15.0; the Application must override it)"
replicas=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.spec.replicas}')
[[ "$replicas" == "2" ]] || fail "Deployment scout has $replicas replicas, expected 2 from the overlay"
echo "PASS: overlay built by Argo CD, image overridden to 6.14.0, 2 replicas from the overlay"
