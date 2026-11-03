#!/usr/bin/env bash
# Grades the Alert and its effect: an error event about scout-staging has reached the sink.
set -u
fail() { echo "FAIL: $*"; exit 1; }
a() { kubectl -n flux-system get alert "$1" -o jsonpath="$2" 2>/dev/null; }
name=""
for n in $(kubectl -n flux-system get alert -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
  [[ "$(a "$n" '{.spec.providerRef.name}')" == "sink" ]] || continue
  [[ "$(a "$n" '{.spec.eventSeverity}')" == "error" ]] || continue
  a "$n" '{range .spec.eventSources[*]}{.kind}/{.name}{"\n"}{end}' | grep -qx "Kustomization/scout-staging" || continue
  name="$n"; break
done
[[ -n "$name" ]] || fail "no Alert with providerRef sink, eventSeverity error and the source Kustomization scout-staging"
got=""
for i in $(seq 1 48); do
  if kubectl -n starfleet logs deploy/sink 2>/dev/null | grep '"name":"scout-staging"' | grep -Eq '"severity": ?"error"'; then got=1; break; fi
  sleep 5
done
[[ -n "$got" ]] || fail "the Alert $name exists, but the sink has no error event about scout-staging. Create the Alert while the delivery is still failing"
echo "PASS: Alert $name sends error events and the sink has received one"
