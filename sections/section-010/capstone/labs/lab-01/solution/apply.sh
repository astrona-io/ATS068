#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
PORT=$((30000 + RANDOM % 20000))
kubectl -n gitea port-forward svc/gitea-http "$PORT:3000" >/dev/null 2>&1 &
PF=$!
WORK="$(mktemp -d)"
trap 'kill $PF 2>/dev/null || true; rm -rf "$WORK"' EXIT
for i in $(seq 1 30); do curl -fs "http://127.0.0.1:$PORT/api/v1/version" >/dev/null 2>&1 && break; sleep 1; done
git clone -q "http://platform:starfleet-gitops@127.0.0.1:$PORT/starfleet/scout-deploy.git" "$WORK/repo"
cd "$WORK/repo"
sed -i.bak 's/name: scouts/name: scout/' overlays/preview/message.yaml && rm overlays/preview/message.yaml.bak
git add overlays/preview/message.yaml
git -c user.name=platform -c user.email=platform@starfleet.local commit -q -m "Fix the preview patch target"
git push -q origin main
kubectl apply -f - <<'YAML'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-preview
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/preview
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-preview
  syncPolicy:
    automated:
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML
kubectl -n starfleet-preview wait --for=create deploy/scout --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-preview --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-preview --timeout=240s
