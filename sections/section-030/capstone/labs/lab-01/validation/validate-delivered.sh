#!/usr/bin/env bash
# Grades the result from a client: release 2 is live in both namespaces.
set -u
fail() { echo "FAIL: $*"; exit 1; }
ask() {
  local body=""
  for i in $(seq 1 10); do
    body=$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "http://scout.$1/" 2>/dev/null)
    grep -q '"message"' <<<"$body" && break
    sleep 3
  done
  echo "$body"
}
b=$(ask starfleet-staging);    grep -q '"message": *"staging-v2"' <<<"$b" || fail "staging did not return message staging-v2 (got: ${b:-nothing})"
b=$(ask starfleet-production); grep -q '"message": *"chart-v2"' <<<"$b" || fail "production did not return message chart-v2 (got: ${b:-nothing})"
echo "PASS: staging answers staging-v2 and production answers chart-v2"
