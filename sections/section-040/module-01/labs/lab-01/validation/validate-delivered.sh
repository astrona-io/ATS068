#!/usr/bin/env bash
# Grades the whole path: a push to Git plus one webhook call makes Flux fetch early, apply, and send an event to the sink.
set -u
fail() { echo "FAIL: $*"; exit 1; }
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!; disown
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
path="$(kubectl -n flux-system get receiver scout-push -o jsonpath='{.status.webhookPath}' 2>/dev/null)"
[[ "$path" == /hook/* ]] || fail "the Receiver has no webhook path"
count() { kubectl -n starfleet logs deploy/sink 2>/dev/null | grep -c '"name":"scout-staging"' || true; }
before="$(count)"
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" "$WORK/repo" || fail "cannot clone the repository"
cd "$WORK/repo"
stamp="staging-$(date +%s)"
sed -i.bak "s/value: .*/value: $stamp/" overlays/staging/message.yaml && rm overlays/staging/message.yaml.bak
git add -A
git -c user.name=platform -c user.email=platform@starfleet.local commit -q -m "Message $stamp"
git push -q origin main || fail "cannot push to the repository"
head="$(git rev-parse HEAD)"
kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 10 -X POST "http://webhook-receiver.flux-system.svc$path" >/dev/null 2>&1 || fail "the webhook call from shuttle failed"
ok=""
for i in $(seq 1 36); do
  rev="$(kubectl -n flux-system get gitrepository scout -o jsonpath='{.status.artifact.revision}' 2>/dev/null)"
  [[ "$rev" == *"$head" ]] && { ok=1; break; }
  sleep 5
done
[[ -n "$ok" ]] || fail "the GitRepository did not fetch $head after the webhook; its interval is one hour, so only the Receiver can trigger it"
got=""
for i in $(seq 1 36); do
  [[ "$(count)" -gt "$before" ]] && { got=1; break; }
  sleep 5
done
[[ -n "$got" ]] || fail "the sink received no new event about the Kustomization scout-staging"
echo "PASS: the webhook made Flux fetch $head and an event reached the sink"
