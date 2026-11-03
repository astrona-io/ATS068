#!/usr/bin/env bash
# Grades the definition: automated sync with prune and self-heal, namespace creation, same source.
set -u
fail() { echo "FAIL: $*"; exit 1; }
kubectl -n argocd get application scout >/dev/null 2>&1 || fail "no Application scout in the namespace argocd; do not delete it"
get() { kubectl -n argocd get application scout -o jsonpath="$1" 2>/dev/null; }
[[ "$(get '{.spec.source.targetRevision}')" == "main" && "$(get '{.spec.source.path}')" == "overlays/staging" ]] || fail "the source must stay branch main, path overlays/staging"
[[ "$(get '{.spec.destination.namespace}')" == "starfleet-staging" ]] || fail "destination namespace must stay starfleet-staging"
[[ "$(get '{.spec.syncPolicy.automated.prune}')" == "true" ]] || fail "syncPolicy.automated.prune is not true"
[[ "$(get '{.spec.syncPolicy.automated.selfHeal}')" == "true" ]] || fail "syncPolicy.automated.selfHeal is not true"
[[ " $(get '{.spec.syncPolicy.syncOptions[*]}') " == *" CreateNamespace=true "* ]] || fail "syncOptions must contain CreateNamespace=true"
echo "PASS: automated sync with prune and self-heal, and CreateNamespace=true"
