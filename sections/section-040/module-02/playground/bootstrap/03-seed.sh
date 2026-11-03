#!/usr/bin/env bash
# Plumbing: push the repository, create the Secret that lets Flux read and push, and the two target namespaces.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/seed-repo.sh" scout-deploy "$SCRIPT_DIR/../repos/scout-deploy"
kubectl -n flux-system create secret generic scout-write --from-literal=username=platform --from-literal=password=starfleet-gitops
kubectl create namespace starfleet-staging
kubectl create namespace starfleet-production
