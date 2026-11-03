#!/usr/bin/env bash
# Grades the Flux source: OCIRepository scout-oci follows the 1.0.x range over plain HTTP and is Ready.
set -u
fail() { echo "FAIL: $*"; exit 1; }
g() { kubectl -n flux-system get ocirepository scout-oci -o jsonpath="$1" 2>/dev/null; }
kubectl -n flux-system get ocirepository scout-oci >/dev/null 2>&1 || fail "no OCIRepository scout-oci in flux-system"
[[ "$(g '{.spec.url}')" == "oci://registry.registry.svc:5000/scout-manifests" ]] || fail "spec.url is '$(g '{.spec.url}')', expected oci://registry.registry.svc:5000/scout-manifests"
[[ "$(g '{.spec.ref.semver}')" == "1.0.x" ]] || fail "spec.ref.semver is '$(g '{.spec.ref.semver}')', expected 1.0.x"
[[ "$(g '{.spec.insecure}')" == "true" ]] || fail "spec.insecure must be true because the registry speaks plain HTTP"
[[ "$(g '{.status.conditions[?(@.type=="Ready")].status}')" == "True" ]] || fail "OCIRepository scout-oci is not Ready: $(g '{.status.conditions[?(@.type=="Ready")].message}')"
rev="$(g '{.status.artifact.revision}')"
[[ "$rev" == 1.0.0@sha256:* ]] || fail "status.artifact.revision is '$rev', expected 1.0.0@sha256:<digest>"
echo "PASS: OCIRepository scout-oci is Ready on revision $rev"
