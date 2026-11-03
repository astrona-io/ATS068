# Solution

## Step 1: Read why nothing is delivered

```sh
kubectl -n argocd get application scout
kubectl -n argocd get application scout -o jsonpath='{.spec.syncPolicy}{"\n"}'
```

The sync policy is empty, so the controller only compares and reports `OutOfSync`. The objects are missing, so the health is `Missing`.

## Step 2: Set the sync policy

Save this as `application-scout.yaml`:

```yaml
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
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply it:

```sh
kubectl apply -f application-scout.yaml
```

`automated` makes the controller start the sync by itself. `prune` lets it delete objects that Git no longer holds. `selfHeal` lets it revert cluster changes. `CreateNamespace=true` creates the namespace before the objects are applied.

Run `astrona submit`. The check `sync-policy` should pass.

## Step 3: Wait for the delivery

```sh
kubectl -n argocd wait --for=jsonpath='{.status.sync.status}'=Synced application/scout --timeout=240s
kubectl -n argocd wait --for=jsonpath='{.status.health.status}'=Healthy application/scout --timeout=240s
```

Run `astrona submit` again. The check `delivered` should pass.

## Step 4: See self-heal work

The last check scales the Deployment to 3 replicas and waits for Argo CD to set it back to 1. You can try it yourself first:

```sh
kubectl -n starfleet-staging scale deploy/scout --replicas=3
kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.replicas}{"\n"}'
```

Run the second command again after a short wait. The replicas return to 1. If they do not, `selfHeal` is missing or `automated` is not set.
