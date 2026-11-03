# Solution

## Step 1: Create the Secret and the Receiver

The Receiver needs a Secret with a `token` key in its own namespace:

```sh
kubectl -n flux-system create secret generic webhook-token --from-literal=token=starfleet-hook
```

Save this as `receiver-scout-push.yaml`:

```yaml
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Receiver
metadata:
  name: scout-push
  namespace: flux-system
spec:
  type: generic
  secretRef:
    name: webhook-token
  resources:
    - apiVersion: source.toolkit.fluxcd.io/v1
      kind: GitRepository
      name: scout
      namespace: flux-system
```

Apply it and read the path:

```sh
kubectl apply -f receiver-scout-push.yaml
kubectl -n flux-system wait receiver/scout-push --for=condition=Ready --timeout=120s
kubectl -n flux-system get receiver scout-push -o jsonpath='{.status.webhookPath}{"\n"}'
```

The path starts with `/hook/` and ends with a hash of the token, the name and the namespace. A POST to this path on the Service `webhook-receiver` makes Flux fetch the source at once.

Run `astrona submit`. The check `receiver` should pass.

## Step 2: Create the Provider and the Alert

Save this as `notify-sink.yaml`:

```yaml
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Provider
metadata:
  name: sink
  namespace: flux-system
spec:
  type: generic
  address: http://sink.starfleet.svc/cgi-bin/events
---
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Alert
metadata:
  name: scout-events
  namespace: flux-system
spec:
  providerRef:
    name: sink
  eventSeverity: info
  eventSources:
    - kind: Kustomization
      name: scout-staging
```

Apply it:

```sh
kubectl apply -f notify-sink.yaml
```

The Provider is the destination. The Alert selects the events of the Kustomization and sends them to the Provider. Run `astrona submit`. The check `alert` should pass.

## Step 3: Try the whole path yourself

Push a change to Git, call the webhook from `shuttle`, and read the sink:

```sh
PATH_HOOK="$(kubectl -n flux-system get receiver scout-push -o jsonpath='{.status.webhookPath}')"
kubectl -n starfleet exec deploy/shuttle -- curl -s -X POST "http://webhook-receiver.flux-system.svc$PATH_HOOK"
kubectl -n flux-system get gitrepository scout -o jsonpath='{.status.artifact.revision}{"\n"}'
kubectl -n starfleet logs deploy/sink
```

After a push, the revision of the source changes within seconds, although its interval is one hour. The Kustomization then applies the change and the sink log gets a line about it. Run `astrona submit` again. The check `delivered` pushes its own commit and should pass.
