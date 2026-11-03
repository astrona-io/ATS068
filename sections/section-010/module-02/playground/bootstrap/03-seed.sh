#!/usr/bin/env bash
# Plumbing: push the repository into Gitea and give Argo CD the repository credentials.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/seed-repo.sh" scout-deploy "$SCRIPT_DIR/../repos/scout-deploy"
kubectl apply -f - >/dev/null <<'YAML'
apiVersion: v1
kind: Secret
metadata:
  name: repo-scout-deploy
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  username: platform
  password: starfleet-gitops
YAML
