#!/usr/bin/env bash
# Grades the Provider and the Alert definitions.
set -u
fail() { echo "FAIL: $*"; exit 1; }
p() { kubectl -n flux-system get provider sink -o jsonpath="$1" 2>/dev/null; }
a() { kubectl -n flux-system get alert scout-events -o jsonpath="$1" 2>/dev/null; }
kubectl -n flux-system get provider sink >/dev/null 2>&1 || fail "no Provider sink in the namespace flux-system"
[[ "$(p '{.spec.type}')" == "generic" ]] || fail "Provider type is '$(p '{.spec.type}')', expected generic"
[[ "$(p '{.spec.address}')" == "http://sink.starfleet.svc/cgi-bin/events" ]] || fail "Provider address is '$(p '{.spec.address}')', expected http://sink.starfleet.svc/cgi-bin/events"
kubectl -n flux-system get alert scout-events >/dev/null 2>&1 || fail "no Alert scout-events in the namespace flux-system"
[[ "$(a '{.spec.providerRef.name}')" == "sink" ]] || fail "the Alert must use the Provider sink"
src="$(a '{range .spec.eventSources[*]}{.kind}/{.name}{"\n"}{end}')"
grep -qx "Kustomization/scout-staging" <<<"$src" || fail "the Alert must watch the Kustomization scout-staging"
echo "PASS: Provider sink and Alert scout-events are defined"
