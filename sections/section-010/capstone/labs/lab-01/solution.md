# Solution

## Step 1: Find the build error

Clone the repository, using the port forward on port 3000, and build the overlay:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
kubectl kustomize overlays/preview
```

The error says that no resource matches the patch for the Deployment `scouts`. The Kustomize build selects the patch target by the `kind` and `name` in the patch file. The base Deployment is named `scout`, so the patch matches nothing and the build stops.

## Step 2: Fix the patch and push

Change `name: scouts` to `name: scout` in `overlays/preview/message.yaml`, build again, and push:

```sh
sed -i.bak 's/name: scouts/name: scout/' overlays/preview/message.yaml && rm overlays/preview/message.yaml.bak
kubectl kustomize overlays/preview | grep -E 'replicas|namespace|PODINFO' -A1
git add overlays/preview/message.yaml
git commit -m "Fix the preview patch target"
git push origin main
```

Run `astrona submit`. The check `overlay-fixed-in-git` should pass.

## Step 3: Create the Application

Save this as `application-scout-preview.yaml`:

```yaml
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
```

Apply it:

```sh
kubectl apply -f application-scout-preview.yaml
```

Then check the result:

```sh
kubectl -n argocd get application scout-preview
kubectl -n starfleet-preview get deploy scout
```

Run `astrona submit` again. If the Application still shows a comparison error, ask Argo CD to refresh it, because the repo-server caches the repository for a short time:

```sh
kubectl -n argocd annotate application scout-preview argocd.argoproj.io/refresh=hard --overwrite
```
