#!/usr/bin/env bash
# Grades the ImageRepository and the ImagePolicy: scan podinfo, select a 6.15 tag.
set -u
fail() { echo "FAIL: $*"; exit 1; }
r() { kubectl -n flux-system get imagerepository scout -o jsonpath="$1" 2>/dev/null; }
p() { kubectl -n flux-system get imagepolicy scout -o jsonpath="$1" 2>/dev/null; }
kubectl -n flux-system get imagerepository scout >/dev/null 2>&1 || fail "no ImageRepository scout in the namespace flux-system"
[[ "$(r '{.spec.image}')" == "ghcr.io/stefanprodan/podinfo" ]] || fail "ImageRepository image is '$(r '{.spec.image}')', expected ghcr.io/stefanprodan/podinfo"
ok=""
for i in $(seq 1 24); do
  [[ "$(r '{.status.lastScanResult.tagCount}')" -gt 0 ]] 2>/dev/null && { ok=1; break; }
  sleep 5
done
[[ -n "$ok" ]] || fail "the ImageRepository has not scanned any tags yet; read its status conditions"
kubectl -n flux-system get imagepolicy scout >/dev/null 2>&1 || fail "no ImagePolicy scout in the namespace flux-system"
[[ "$(p '{.spec.imageRepositoryRef.name}')" == "scout" ]] || fail "the ImagePolicy must use the ImageRepository scout"
ok=""
for i in $(seq 1 24); do
  tag="$(p '{.status.latestRef.tag}')"
  [[ "$tag" == 6.15.* ]] && { ok=1; break; }
  sleep 5
done
[[ -n "$ok" ]] || fail "the ImagePolicy selected '$(p '{.status.latestRef.tag}')'; it must select a tag in the range 6.15.x"
echo "PASS: ImageRepository scout scans podinfo and ImagePolicy scout selected $(p '{.status.latestRef.tag}')"
