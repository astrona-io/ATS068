#!/usr/bin/env bash
# Grades the ImageUpdateAutomation definition.
set -u
fail() { echo "FAIL: $*"; exit 1; }
a() { kubectl -n flux-system get imageupdateautomation scout -o jsonpath="$1" 2>/dev/null; }
kubectl -n flux-system get imageupdateautomation scout >/dev/null 2>&1 || fail "no ImageUpdateAutomation scout in the namespace flux-system"
[[ "$(a '{.spec.sourceRef.kind}/{.spec.sourceRef.name}')" == "GitRepository/scout" ]] || fail "the automation must use the GitRepository scout as its source"
[[ "$(a '{.spec.git.checkout.ref.branch}')" == "main" ]] || fail "the automation must check out the branch main"
[[ "$(a '{.spec.git.push.branch}')" == "main" ]] || fail "the automation must push to the branch main"
[[ "$(a '{.spec.update.strategy}')" == "Setters" ]] || fail "update strategy is '$(a '{.spec.update.strategy}')', expected Setters"
[[ "$(a '{.spec.update.path}')" == "./overlays/staging" ]] || fail "update path is '$(a '{.spec.update.path}')', expected ./overlays/staging"
[[ "$(a '{.spec.git.commit.author.name}')" == "fluxbot" ]] || fail "the commit author name must be fluxbot"
echo "PASS: ImageUpdateAutomation scout is defined"
