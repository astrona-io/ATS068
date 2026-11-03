# Solution

## Step 1: Read the state

```sh
kubectl -n flux-system get kustomization scout-staging -o jsonpath='{.status.lastAppliedRevision}{"\n"}{.status.lastAttemptedRevision}{"\n"}'
kubectl -n flux-system get kustomization scout-staging -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}{"\n"}'
kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

The attempted revision is newer than the applied revision, and `Ready` is `False`. The newest commit failed. The Deployment already shows the new image, and with `wait: true` the health check fails because the new Pod cannot pull it. The old Pod keeps serving.

## Step 2: Create the Alert

Save this as `alert-scout-failures.yaml`:

```yaml
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Alert
metadata:
  name: scout-failures
  namespace: flux-system
spec:
  providerRef:
    name: sink
  eventSeverity: error
  eventSources:
    - kind: Kustomization
      name: scout-staging
```

Apply it:

```sh
kubectl apply -f alert-scout-failures.yaml
```

The Kustomization retries every minute and records an error event for each failed attempt, so an event reaches the sink after the next attempt. Read it:

```sh
kubectl -n starfleet logs deploy/sink
```

Run `astrona submit`. The check `alert-delivers-errors` should pass once a line with `"severity":"error"` appears.

## Step 3: Record the evidence

The failed revision is the attempted revision without the prefix `main@sha1:`. The image is in the bad commit and in the Deployment:

```sh
FAILED="$(kubectl -n flux-system get kustomization scout-staging -o jsonpath='{.status.lastAttemptedRevision}')"
kubectl -n starfleet create configmap delivery-record --from-literal=failed-revision="${FAILED#main@sha1:}" --from-literal=image=ghcr.io/stefanprodan/podinfo:6.99.0
```

Run `astrona submit`. The check `record` should pass.

## Step 4: Fix forward

Clone the repository, set the tag back, and push a new commit:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
sed -i.bak 's/newTag: 6.99.0/newTag: 6.15.0/' overlays/staging/kustomization.yaml && rm overlays/staging/kustomization.yaml.bak
git add -A
git -c user.name=platform -c user.email=platform@starfleet.local commit -m "Use scout 6.15.0 again"
git push origin main
```

The commit goes on top of the bad one, so the history keeps the evidence. Ask Flux to fetch and apply without waiting for the interval:

```sh
STAMP="$(date +%s)"
kubectl -n flux-system annotate gitrepository/scout --overwrite reconcile.fluxcd.io/requestedAt="$STAMP"
kubectl -n flux-system annotate kustomization/scout-staging --overwrite reconcile.fluxcd.io/requestedAt="$STAMP"
kubectl -n flux-system wait kustomization/scout-staging --for=condition=Ready --timeout=300s
```

Run `astrona submit`. The check `recovered` should pass.
