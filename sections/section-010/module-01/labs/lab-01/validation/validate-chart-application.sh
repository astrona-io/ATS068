#!/usr/bin/env bash
# Grades the definition of the Application scout-chart (Helm input).
set -u
fail() { echo "FAIL: $*"; exit 1; }
REPO_URL="http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git"
kubectl -n argocd get application scout-chart >/dev/null 2>&1 || fail "no Application scout-chart in the namespace argocd"
get() { kubectl -n argocd get application scout-chart -o jsonpath="$1"; }
[[ "$(get '{.spec.source.repoURL}')" == "$REPO_URL" ]] || fail "repoURL is '$(get '{.spec.source.repoURL}')', expected $REPO_URL"
[[ "$(get '{.spec.source.path}')" == "chart" ]] || fail "path is '$(get '{.spec.source.path}')', expected chart"
[[ "$(get '{.spec.source.helm.releaseName}')" == "scout" ]] || fail "helm.releaseName is '$(get '{.spec.source.helm.releaseName}')', expected scout"
[[ "$(get '{.spec.destination.namespace}')" == "starfleet-staging" ]] || fail "destination namespace is '$(get '{.spec.destination.namespace}')', expected starfleet-staging"
values="$(get '{.spec.source.helm.valuesObject}')$(get '{.spec.source.helm.values}')$(get '{.spec.source.helm.parameters}')"
grep -q 'from-chart' <<<"$values" || fail "the Helm values do not set message to from-chart"
echo "PASS: Application scout-chart renders the chart with release name scout and the requested values"
