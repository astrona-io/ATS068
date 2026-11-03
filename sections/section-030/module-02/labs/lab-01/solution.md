# Solution

## Step 1: Create the source

Save this as `gitrepository-scout.yaml`:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: scout
  namespace: flux-system
spec:
  interval: 1m
  url: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  ref:
    branch: main
  secretRef:
    name: scout-readonly
```

Apply it and wait:

```sh
kubectl apply -f gitrepository-scout.yaml
kubectl -n flux-system wait gitrepository/scout --for=condition=Ready --timeout=180s
```

The source controller fetches the repository with the credentials of the Secret and publishes an artifact. If the source is not `Ready`, read the message of the `Ready` condition. A wrong Secret name or branch shows up there.

Run `astrona submit`. The check `source` should pass.

## Step 2: Create the HelmRelease

Save this as `helmrelease-scout-chart.yaml`:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: scout-chart
  namespace: flux-system
spec:
  interval: 5m
  releaseName: scout
  targetNamespace: starfleet-staging
  chart:
    spec:
      chart: ./chart
      reconcileStrategy: Revision
      sourceRef:
        kind: GitRepository
        name: scout
  values:
    replicaCount: 2
    message: from-flux
```

Apply it and wait:

```sh
kubectl apply -f helmrelease-scout-chart.yaml
kubectl -n flux-system wait helmrelease/scout-chart --for=condition=Ready --timeout=300s
```

Flux creates a `HelmChart` from the directory, and the Helm controller runs a Helm install with the values. Check the result:

```sh
kubectl -n starfleet-staging get deploy scout
kubectl get secret -A -l owner=helm,name=scout
```

The Secret is the Helm release record. Argo CD would not create it, because it only renders the chart. Run `astrona submit` again. All three checks should pass.
