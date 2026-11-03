#!/usr/bin/env bash
# Grades the definition of the Application scout-plain (directory source).
set -u
fail() { echo "FAIL: $*"; exit 1; }
REPO_URL="http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git"
kubectl -n argocd get application scout-plain >/dev/null 2>&1 || fail "no Application scout-plain in the namespace argocd"
get() { kubectl -n argocd get application scout-plain -o jsonpath="$1"; }
[[ "$(get '{.spec.source.repoURL}')" == "$REPO_URL" ]] || fail "repoURL is '$(get '{.spec.source.repoURL}')', expected $REPO_URL"
[[ "$(get '{.spec.source.path}')" == "plain" ]] || fail "path is '$(get '{.spec.source.path}')', expected plain"
[[ "$(get '{.spec.source.directory.recurse}')" == "true" ]] || fail "directory.recurse is not true, so the manifest in the sub-directory extra/ is not read"
exclude="$(get '{.spec.source.directory.exclude}')"
grep -q 'drafts' <<<"$exclude" || fail "directory.exclude does not exclude the drafts folder (got: '${exclude}')"
[[ "$(get '{.spec.destination.namespace}')" == "starfleet-staging" ]] || fail "destination namespace is '$(get '{.spec.destination.namespace}')', expected starfleet-staging"
echo "PASS: Application scout-plain reads plain/ recursively and excludes drafts"
