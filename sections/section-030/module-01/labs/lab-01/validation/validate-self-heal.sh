#!/usr/bin/env bash
# Grades behaviour: a manual change in the cluster is reverted by Argo CD.
set -u
fail() { echo "FAIL: $*"; exit 1; }
NS="starfleet-staging"
kubectl -n "$NS" get deploy scout >/dev/null 2>&1 || fail "Deployment scout does not exist in $NS"
kubectl -n "$NS" scale deploy/scout --replicas=3 >/dev/null || fail "cannot scale the Deployment"
back=""
for i in $(seq 1 40); do
  back=$(kubectl -n "$NS" get deploy scout -o jsonpath='{.spec.replicas}')
  [[ "$back" == "1" ]] && break
  sleep 3
done
[[ "$back" == "1" ]] || fail "the Deployment still has $back replicas after 120 seconds; Argo CD did not revert the manual change"
echo "PASS: Argo CD reverted the manual change back to 1 replica"
