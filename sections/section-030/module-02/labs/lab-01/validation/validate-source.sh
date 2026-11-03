#!/usr/bin/env bash
# Grades the Flux source: GitRepository scout follows main with the read-only Secret and is Ready.
set -u
fail() { echo "FAIL: $*"; exit 1; }
g() { kubectl -n flux-system get gitrepository scout -o jsonpath="$1" 2>/dev/null; }
kubectl -n flux-system get gitrepository scout >/dev/null 2>&1 || fail "no GitRepository scout in flux-system"
[[ "$(g '{.spec.url}')" == "http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git" ]] || fail "wrong spec.url"
[[ "$(g '{.spec.ref.branch}')" == "main" ]] || fail "spec.ref.branch is '$(g '{.spec.ref.branch}')', expected main"
[[ "$(g '{.spec.secretRef.name}')" == "scout-readonly" ]] || fail "spec.secretRef.name must be scout-readonly"
[[ "$(g '{.status.conditions[?(@.type=="Ready")].status}')" == "True" ]] || fail "GitRepository scout is not Ready: $(g '{.status.conditions[?(@.type=="Ready")].message}')"
[[ -n "$(g '{.status.artifact.revision}')" ]] || fail "the GitRepository has no artifact yet"
echo "PASS: GitRepository scout is Ready on main with the read-only Secret"
