#!/usr/bin/env bash
# Grades the AppProject starfleet: one source repository, two destination namespaces, only Namespace as a cluster resource.
set -u
fail() { echo "FAIL: $*"; exit 1; }
REPO_URL="http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git"
kubectl -n argocd get appproject starfleet >/dev/null 2>&1 || fail "no AppProject starfleet in the namespace argocd"
p() { kubectl -n argocd get appproject starfleet -o jsonpath="$1" 2>/dev/null; }
[[ "$(p '{.spec.sourceRepos[*]}')" == "$REPO_URL" ]] || fail "spec.sourceRepos is '$(p '{.spec.sourceRepos[*]}')', expected only $REPO_URL"
dest="$(p '{range .spec.destinations[*]}{.server}/{.namespace}{"\n"}{end}')"
grep -qx 'https://kubernetes.default.svc/starfleet-staging' <<<"$dest" || fail "destinations do not allow starfleet-staging on https://kubernetes.default.svc"
grep -qx 'https://kubernetes.default.svc/starfleet-production' <<<"$dest" || fail "destinations do not allow starfleet-production on https://kubernetes.default.svc"
[[ "$(wc -l <<<"$dest" | tr -d ' ')" == "2" ]] || fail "the project must allow exactly two destinations (got: $dest)"
kinds="$(p '{range .spec.clusterResourceWhitelist[*]}{.kind}{"\n"}{end}')"
[[ "$kinds" == "Namespace" ]] || fail "clusterResourceWhitelist must allow only the kind Namespace (got: '${kinds}')"
echo "PASS: AppProject starfleet allows one repository, two namespaces and only Namespace as cluster resource"
