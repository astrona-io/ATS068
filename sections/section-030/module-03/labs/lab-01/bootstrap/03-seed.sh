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
kubectl apply -f - >/dev/null <<'YAML'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
YAML
