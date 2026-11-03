#!/usr/bin/env bash
# Grades the recovery: a new commit fixes the tag, history is intact, Flux applied the head, staging works.
set -u
fail() { echo "FAIL: $*"; exit 1; }
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!; disown
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" "$WORK/repo" || fail "cannot clone the repository"
cd "$WORK/repo"
bad="$(git log --format=%H --grep='Bump scout to 6.99.0' -n 1)"
[[ -n "$bad" ]] || fail "the bad commit is not in the history; fix forward, do not rewrite history"
head="$(git rev-parse HEAD)"
[[ "$head" != "$bad" ]] || fail "main still points at the bad commit"
git merge-base --is-ancestor "$bad" "$head" || fail "history was rewritten; add a commit on top instead"
k() { kubectl -n flux-system get kustomization scout-staging -o jsonpath="$1" 2>/dev/null; }
[[ "$(k '{.spec.wait}')" == "true" && "$(k '{.spec.path}')" == "./overlays/staging" ]] || fail "do not change spec.wait or spec.path of scout-staging"
ok=""
for i in $(seq 1 48); do
  if [[ "$(k '{.status.conditions[?(@.type=="Ready")].status}')" == "True" && "$(k '{.status.lastAppliedRevision}')" == *"$head" ]]; then ok=1; break; fi
  sleep 5
done
[[ -n "$ok" ]] || fail "scout-staging is not Ready on $head yet (applied: '$(k '{.status.lastAppliedRevision}')'). Reconcile the source and the Kustomization"
img="$(kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)"
[[ "$img" == "ghcr.io/stefanprodan/podinfo:6.15.0" ]] || fail "staging runs image '$img', expected ghcr.io/stefanprodan/podinfo:6.15.0"
body=""
for i in $(seq 1 10); do
  body="$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 http://scout.starfleet-staging/ 2>/dev/null)"
  grep -q '"version"' <<<"$body" && break
  sleep 3
done
grep -q '"version": *"6.15.0"' <<<"$body" || fail "scout answers '${body:-nothing}', expected version 6.15.0"
echo "PASS: staging is on 6.15.0 from $head and the bad commit is still in the history"
