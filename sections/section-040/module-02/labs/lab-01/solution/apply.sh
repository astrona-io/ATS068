#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`. Keep in step with solution.md.
set -euo pipefail
kubectl apply -f - <<'YAML'
apiVersion: image.toolkit.fluxcd.io/v1
kind: ImageRepository
metadata:
  name: scout
  namespace: flux-system
spec:
  image: ghcr.io/stefanprodan/podinfo
  interval: 1m
---
apiVersion: image.toolkit.fluxcd.io/v1
kind: ImagePolicy
metadata:
  name: scout
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: scout
  policy:
    semver:
      range: 6.15.x
---
apiVersion: image.toolkit.fluxcd.io/v1
kind: ImageUpdateAutomation
metadata:
  name: scout
  namespace: flux-system
spec:
  interval: 1m
  sourceRef:
    kind: GitRepository
    name: scout
  git:
    checkout:
      ref:
        branch: main
    commit:
      author:
        name: fluxbot
        email: fluxbot@starfleet.local
      messageTemplate: 'Update image to {{range .Changed.Changes}}{{.NewValue}}{{end}}'
    push:
      branch: main
  update:
    path: ./overlays/staging
    strategy: Setters
YAML
kubectl -n flux-system wait --for=condition=Ready imagepolicy/scout --timeout=180s
kubectl -n flux-system wait --for=condition=Ready imageupdateautomation/scout --timeout=180s
