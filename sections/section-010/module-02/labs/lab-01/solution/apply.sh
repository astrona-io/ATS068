#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
kubectl apply -f - <<'YAML'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-plain
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: plain
    directory:
      recurse: true
      exclude: 'drafts/*'
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-jsonnet
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: jsonnet
    directory:
      jsonnet:
        extVars:
          - name: replicas
            value: "2"
          - name: message
            value: from-jsonnet
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-production
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
YAML
kubectl -n starfleet-staging wait --for=create deploy/scout --timeout=180s
kubectl -n starfleet-production wait --for=create deploy/scout --timeout=180s
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-plain application/scout-jsonnet --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-plain application/scout-jsonnet --timeout=240s
