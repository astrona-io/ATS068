# Solution

## Step 1: Render the chart

Save this as `application-scout-chart.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-chart
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: chart
    helm:
      releaseName: scout
      valuesObject:
        replicaCount: 2
        message: from-chart
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

Apply it:

```sh
kubectl apply -f application-scout-chart.yaml
```

Then check the result. The repo-server component of Argo CD runs `helm template` with your release name and values, and the application controller applies the output:

```sh
kubectl -n argocd get application scout-chart
kubectl -n starfleet-staging get deploy scout
```

Run `astrona submit`. The two checks for `scout-chart` should pass. If `delivered` fails with a missing namespace, check that `CreateNamespace=true` is in the sync options.

## Step 2: Build the overlay with an image override

Save this as `application-scout-overlay.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-overlay
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/production
    kustomize:
      images:
        - ghcr.io/stefanprodan/podinfo:6.14.0
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-production
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

Apply it:

```sh
kubectl apply -f application-scout-overlay.yaml
```

Then check the image that runs:

```sh
kubectl -n starfleet-production get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}'
```

Run `astrona submit` again. All four checks should pass. The overlay still says `6.15.0` in Git. Argo CD runs `kustomize edit set image` on a copy of the overlay before it builds, so the live image is `6.14.0`.
