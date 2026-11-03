#!/usr/bin/env bash
# Grades the HelmRelease definition: chart from the GitRepository, release name, namespace, values.
set -u
fail() { echo "FAIL: $*"; exit 1; }
h() { kubectl -n flux-system get helmrelease scout-chart -o jsonpath="$1" 2>/dev/null; }
kubectl -n flux-system get helmrelease scout-chart >/dev/null 2>&1 || fail "no HelmRelease scout-chart in flux-system"
[[ "$(h '{.spec.chart.spec.chart}')" == "./chart" ]] || fail "spec.chart.spec.chart is '$(h '{.spec.chart.spec.chart}')', expected ./chart"
[[ "$(h '{.spec.chart.spec.sourceRef.kind}')" == "GitRepository" && "$(h '{.spec.chart.spec.sourceRef.name}')" == "scout" ]] || fail "the chart must come from the GitRepository scout"
[[ "$(h '{.spec.releaseName}')" == "scout" ]] || fail "spec.releaseName must be scout"
[[ "$(h '{.spec.targetNamespace}')" == "starfleet-staging" ]] || fail "spec.targetNamespace must be starfleet-staging"
[[ "$(h '{.spec.values.replicaCount}')" == "2" ]] || fail "spec.values.replicaCount must be 2"
[[ "$(h '{.spec.values.message}')" == "from-flux" ]] || fail "spec.values.message must be from-flux"
[[ "$(h '{.spec.suspend}')" != "true" ]] || fail "the HelmRelease is suspended"
echo "PASS: HelmRelease scout-chart renders ./chart from scout with the required release name, namespace and values"
