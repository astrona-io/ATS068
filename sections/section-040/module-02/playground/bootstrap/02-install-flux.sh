#!/usr/bin/env bash
# Install Flux 2.9.6 from the release's install.yaml. The flux command-line tool
# on the machine can be newer and refuses `flux install --version=v2.9.6`. The
# image controllers are used here and stay on. The source-watcher is not used and is scaled to zero.
set -euo pipefail
kubectl apply --server-side -f https://github.com/fluxcd/flux2/releases/download/v2.9.6/install.yaml >/dev/null
kubectl -n flux-system scale deploy/source-watcher --replicas=0
for controller in source-controller kustomize-controller helm-controller notification-controller image-reflector-controller image-automation-controller; do
  kubectl -n flux-system rollout status deploy/$controller --timeout=300s
done
