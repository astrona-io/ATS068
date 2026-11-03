#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
kubectl apply -f - <<'YAML'
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: starfleet
  namespace: argocd
spec:
  description: Applications of the drifter team
  sourceRepos:
    - http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  destinations:
    - server: https://kubernetes.default.svc
      namespace: starfleet-staging
    - server: https://kubernetes.default.svc
      namespace: starfleet-production
  clusterResourceWhitelist:
    - group: ""
      kind: Namespace
---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: scout-envs
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - env: staging
            namespace: starfleet-staging
          - env: production
            namespace: starfleet-production
  template:
    metadata:
      name: 'scout-{{env}}'
    spec:
      project: starfleet
      source:
        repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
        targetRevision: main
        path: 'overlays/{{env}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{namespace}}'
      syncPolicy:
        automated: {}
        syncOptions:
          - CreateNamespace=true
YAML
kubectl -n argocd wait --for=create application/scout-staging application/scout-production --timeout=120s
kubectl -n starfleet-staging wait --for=create deploy/scout --timeout=180s
kubectl -n starfleet-production wait --for=create deploy/scout --timeout=180s
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout-staging application/scout-production --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout-staging application/scout-production --timeout=240s
