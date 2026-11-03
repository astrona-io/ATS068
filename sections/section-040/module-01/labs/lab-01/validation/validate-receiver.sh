#!/usr/bin/env bash
# Grades the Receiver: generic type, Secret, targets the GitRepository scout, Ready with a webhook path.
set -u
fail() { echo "FAIL: $*"; exit 1; }
r() { kubectl -n flux-system get receiver scout-push -o jsonpath="$1" 2>/dev/null; }
kubectl -n flux-system get receiver scout-push >/dev/null 2>&1 || fail "no Receiver scout-push in the namespace flux-system"
[[ "$(r '{.spec.type}')" == "generic" ]] || fail "Receiver type is '$(r '{.spec.type}')', expected generic"
[[ "$(r '{.spec.secretRef.name}')" == "webhook-token" ]] || fail "Receiver must use the Secret webhook-token"
res="$(r '{range .spec.resources[*]}{.kind}/{.name}{"\n"}{end}')"
grep -qx "GitRepository/scout" <<<"$res" || fail "the Receiver must list the GitRepository scout in spec.resources"
[[ "$(r '{.status.conditions[?(@.type=="Ready")].status}')" == "True" ]] || fail "Receiver is not Ready: $(r '{.status.conditions[?(@.type=="Ready")].message}')"
[[ "$(r '{.status.webhookPath}')" == /hook/* ]] || fail "the Receiver has no webhook path yet"
echo "PASS: Receiver scout-push is Ready at $(r '{.status.webhookPath}')"
