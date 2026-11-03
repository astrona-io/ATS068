#!/usr/bin/env bash
# Grades that Argo CD can render the overlay: no ComparisonError condition.
set -u
fail() { echo "FAIL: $*"; exit 1; }
kubectl -n argocd get application scout-preview >/dev/null 2>&1 || fail "no Application scout-preview"
types=$(kubectl -n argocd get application scout-preview -o jsonpath='{.status.conditions[*].type}')
[[ "$types" != *ComparisonError* ]] || fail "the Application has a ComparisonError: $(kubectl -n argocd get application scout-preview -o jsonpath='{.status.conditions[?(@.type=="ComparisonError")].message}' | head -c 300)"
echo "PASS: Argo CD renders overlays/preview without a comparison error"
