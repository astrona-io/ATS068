#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
kubectl -n flux-system create secret generic webhook-token --from-literal=token=starfleet-hook
kubectl apply -f - <<'YAML'
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Receiver
metadata:
  name: scout-push
  namespace: flux-system
spec:
  type: generic
  secretRef:
    name: webhook-token
  resources:
    - apiVersion: source.toolkit.fluxcd.io/v1
      kind: GitRepository
      name: scout
      namespace: flux-system
---
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Provider
metadata:
  name: sink
  namespace: flux-system
spec:
  type: generic
  address: http://sink.starfleet.svc/cgi-bin/events
---
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Alert
metadata:
  name: scout-events
  namespace: flux-system
spec:
  providerRef:
    name: sink
  eventSeverity: info
  eventSources:
    - kind: Kustomization
      name: scout-staging
YAML
kubectl -n flux-system wait receiver/scout-push --for=condition=Ready --timeout=120s
