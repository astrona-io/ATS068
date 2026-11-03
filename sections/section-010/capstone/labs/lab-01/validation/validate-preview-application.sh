#!/usr/bin/env bash
# Grades the definition of the Application scout-preview.
set -u
fail() { echo "FAIL: $*"; exit 1; }
REPO_URL="http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git"
kubectl -n argocd get application scout-preview >/dev/null 2>&1 || fail "no Application scout-preview in the namespace argocd"
get() { kubectl -n argocd get application scout-preview -o jsonpath="$1"; }
[[ "$(get '{.spec.source.repoURL}')" == "$REPO_URL" ]] || fail "repoURL is '$(get '{.spec.source.repoURL}')', expected $REPO_URL"
[[ "$(get '{.spec.source.path}')" == "overlays/preview" ]] || fail "path is '$(get '{.spec.source.path}')', expected overlays/preview"
[[ "$(get '{.spec.source.targetRevision}')" == "main" ]] || fail "targetRevision is '$(get '{.spec.source.targetRevision}')', expected main"
[[ "$(get '{.spec.destination.namespace}')" == "starfleet-preview" ]] || fail "destination namespace is '$(get '{.spec.destination.namespace}')', expected starfleet-preview"
[[ "$(get '{.spec.syncPolicy.automated.selfHeal}')" == "true" ]] || fail "syncPolicy.automated.selfHeal is not true"
echo "PASS: Application scout-preview points at overlays/preview with automated sync and self-heal"
