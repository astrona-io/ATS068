#!/usr/bin/env bash
# Grades the Kustomization definition: it reads the OCIRepository, applies to the staging namespace and prunes.
set -u
fail() { echo "FAIL: $*"; exit 1; }
k() { kubectl -n flux-system get kustomization scout-oci -o jsonpath="$1" 2>/dev/null; }
kubectl -n flux-system get kustomization scout-oci >/dev/null 2>&1 || fail "no Kustomization scout-oci in flux-system"
[[ "$(k '{.spec.sourceRef.kind}')" == "OCIRepository" && "$(k '{.spec.sourceRef.name}')" == "scout-oci" ]] || fail "spec.sourceRef must be the OCIRepository scout-oci"
[[ "$(k '{.spec.targetNamespace}')" == "starfleet-staging" ]] || fail "spec.targetNamespace must be starfleet-staging"
[[ "$(k '{.spec.prune}')" == "true" ]] || fail "spec.prune must be true"
[[ "$(k '{.spec.suspend}')" != "true" ]] || fail "the Kustomization is suspended"
echo "PASS: Kustomization scout-oci reads the OCIRepository and applies to starfleet-staging with prune"
