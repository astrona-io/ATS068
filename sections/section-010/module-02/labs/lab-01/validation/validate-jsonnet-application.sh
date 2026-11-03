#!/usr/bin/env bash
# Grades the definition of the Application scout-jsonnet (Jsonnet with external variables).
set -u
fail() { echo "FAIL: $*"; exit 1; }
REPO_URL="http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git"
kubectl -n argocd get application scout-jsonnet >/dev/null 2>&1 || fail "no Application scout-jsonnet in the namespace argocd"
get() { kubectl -n argocd get application scout-jsonnet -o jsonpath="$1"; }
[[ "$(get '{.spec.source.repoURL}')" == "$REPO_URL" ]] || fail "repoURL is '$(get '{.spec.source.repoURL}')', expected $REPO_URL"
[[ "$(get '{.spec.source.path}')" == "jsonnet" ]] || fail "path is '$(get '{.spec.source.path}')', expected jsonnet"
[[ "$(get '{.spec.destination.namespace}')" == "starfleet-production" ]] || fail "destination namespace is '$(get '{.spec.destination.namespace}')', expected starfleet-production"
ext="$(get '{.spec.source.directory.jsonnet.extVars}')"
grep -q 'replicas' <<<"$ext" || fail "directory.jsonnet.extVars does not set replicas"
grep -q 'message' <<<"$ext" || fail "directory.jsonnet.extVars does not set message"
echo "PASS: Application scout-jsonnet passes replicas and message as external variables"
