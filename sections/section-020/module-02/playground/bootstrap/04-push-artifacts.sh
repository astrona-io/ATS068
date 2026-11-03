#!/usr/bin/env bash
# Plumbing: push two versions of the scout manifests to the in-cluster registry as OCI artifacts
# (tags 1.0.0 and 1.1.0), with the flux command-line image running in a Job.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl -n registry rollout status deploy/registry --timeout=300s
kubectl -n registry create configmap artifact-v1 --from-file="$SCRIPT_DIR/../artifacts/v1"
kubectl -n registry create configmap artifact-v2 --from-file="$SCRIPT_DIR/../artifacts/v2"
kubectl apply -f - >/dev/null <<'YAML'
apiVersion: batch/v1
kind: Job
metadata:
  name: push-artifacts
  namespace: registry
spec:
  backoffLimit: 6
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: flux
          image: ghcr.io/fluxcd/flux-cli:v2.9.6
          command:
            - sh
            - -c
            - >-
              flux push artifact oci://registry.registry.svc:5000/scout-manifests:1.0.0
              --path=/artifacts/v1 --source=scout-deploy --revision=1.0.0 --insecure-registry &&
              flux push artifact oci://registry.registry.svc:5000/scout-manifests:1.1.0
              --path=/artifacts/v2 --source=scout-deploy --revision=1.1.0 --insecure-registry
          volumeMounts:
            - name: v1
              mountPath: /artifacts/v1
            - name: v2
              mountPath: /artifacts/v2
      volumes:
        - name: v1
          configMap:
            name: artifact-v1
        - name: v2
          configMap:
            name: artifact-v2
YAML
kubectl -n registry wait --for=condition=complete job/push-artifacts --timeout=300s
echo "[playground] Pushed scout-manifests:1.0.0 and scout-manifests:1.1.0"
