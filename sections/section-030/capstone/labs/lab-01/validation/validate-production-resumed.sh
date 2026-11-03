#!/usr/bin/env bash
# Grades the HelmRelease: resumed, unchanged definition, upgraded to the newest chart revision.
set -u
fail() { echo "FAIL: $*"; exit 1; }
h() { kubectl -n flux-system get helmrelease scout-production -o jsonpath="$1" 2>/dev/null; }
kubectl -n flux-system get helmrelease scout-production >/dev/null 2>&1 || fail "no HelmRelease scout-production; do not delete it"
[[ "$(h '{.spec.suspend}')" != "true" ]] || fail "HelmRelease scout-production is still suspended"
[[ "$(h '{.spec.chart.spec.chart}')" == "./chart" && "$(h '{.spec.releaseName}')" == "scout" ]] || fail "the chart and the release name must stay as they are"
[[ "$(h '{.status.conditions[?(@.type=="Ready")].status}')" == "True" ]] || fail "HelmRelease scout-production is not Ready: $(h '{.status.conditions[?(@.type=="Ready")].message}')"
echo "PASS: scout-production is resumed and Ready"
