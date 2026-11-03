#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!
trap 'kill $PF 2>/dev/null || true' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
COMMIT=$(git ls-remote "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" refs/tags/v1.0.0 | cut -f1)
kubectl apply -f - <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-release
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: $COMMIT
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
YAML
kubectl -n starfleet-staging wait --for=create deploy/scout --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-release --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-release --timeout=240s
