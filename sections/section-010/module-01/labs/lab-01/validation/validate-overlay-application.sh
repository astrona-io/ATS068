#!/usr/bin/env bash
# Grades the definition of the Application scout-overlay (Kustomize input).
set -u
fail() { echo "FAIL: $*"; exit 1; }
REPO_URL="http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git"
kubectl -n argocd get application scout-overlay >/dev/null 2>&1 || fail "no Application scout-overlay in the namespace argocd"
get() { kubectl -n argocd get application scout-overlay -o jsonpath="$1"; }
[[ "$(get '{.spec.source.repoURL}')" == "$REPO_URL" ]] || fail "repoURL is '$(get '{.spec.source.repoURL}')', expected $REPO_URL"
[[ "$(get '{.spec.source.path}')" == "overlays/production" ]] || fail "path is '$(get '{.spec.source.path}')', expected overlays/production"
[[ "$(get '{.spec.destination.namespace}')" == "starfleet-production" ]] || fail "destination namespace is '$(get '{.spec.destination.namespace}')', expected starfleet-production"
[[ "$(get '{.spec.source.kustomize.images[*]}')" == *"ghcr.io/stefanprodan/podinfo:6.14.0"* ]] || fail "spec.source.kustomize.images does not contain ghcr.io/stefanprodan/podinfo:6.14.0"
echo "PASS: Application scout-overlay builds overlays/production with the image override"
