#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
kubectl apply -f - <<'YAML'
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Alert
metadata:
  name: scout-failures
  namespace: flux-system
spec:
  providerRef:
    name: sink
  eventSeverity: error
  eventSources:
    - kind: Kustomization
      name: scout-staging
YAML
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
# Wait for an error event to reach the sink.
for i in $(seq 1 60); do
  kubectl -n starfleet logs deploy/sink 2>/dev/null | grep '"name":"scout-staging"' | grep -Eq '"severity": ?"error"' && break
  sleep 5
done
BAD="$(kubectl -n flux-system get kustomization scout-staging -o jsonpath='{.status.lastAttemptedRevision}')"
kubectl -n starfleet create configmap delivery-record --from-literal=failed-revision="${BAD#main@sha1:}" --from-literal=image=ghcr.io/stefanprodan/podinfo:6.99.0
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" "$WORK/repo"
cd "$WORK/repo"
sed -i.bak 's/newTag: 6.99.0/newTag: 6.15.0/' overlays/staging/kustomization.yaml && rm overlays/staging/kustomization.yaml.bak
git add -A
git -c user.name=platform -c user.email=platform@starfleet.local commit -q -m "Use scout 6.15.0 again"
git push -q origin main
STAMP="$(date +%s)"
kubectl -n flux-system annotate gitrepository/scout --overwrite reconcile.fluxcd.io/requestedAt="$STAMP"
kubectl -n flux-system annotate kustomization/scout-staging --overwrite reconcile.fluxcd.io/requestedAt="$STAMP"
kubectl -n flux-system wait kustomization/scout-staging --for=condition=Ready --timeout=300s
