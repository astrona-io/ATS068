---
draft: true
exam_objectives:
- Interoperability with Notifications, Observability, and Continuous Integration Tools
---
# Notifications: Events, Providers, Alerts And Receivers

A notification connects the engine to people and other tools. It runs in two directions. Outbound, the engine tells chat, a ticket system or a CI job that something happened. Inbound, a Git host or a CI job tells the engine to act now. This part explains both directions in Flux, with the objects and the request each one sends or accepts, and then shows how Argo CD does the same.

## Events as the source

Every Flux controller records events for the objects it handles, for example when a source stores a new artifact, when a Kustomization applies changes, or when a HelmRelease upgrade fails. Each event has a severity, `info` or `error`, a reason, a message, and the object it is about. The events are Kubernetes events, and the controllers also send them to the notification controller, which decides who receives them.

An event is a fact about one reconcile attempt, not a state. A failing Kustomization produces an error event for every attempt, so the same failure can arrive again and again until it is fixed.

## Provider, Alert and Receiver

Three objects in the notification API cover the two directions. They live in the group `notification.toolkit.fluxcd.io`.

A `Provider` describes a destination. Its `spec.type` selects the format, for example a chat service, a Git commit status, or `generic` for a plain HTTP POST. The field `spec.address` holds the target address, and an optional `secretRef` supplies a token or extra headers. With the `generic` type, the body is a JSON object with the fields `involvedObject`, `severity`, `reason`, `message`, `metadata`, `reportingController` and `timestamp`, and a header `Gotk-Component` names the controller that sent it.

An `Alert` connects sources to a Provider. It has a `providerRef`, a list of `eventSources` with a kind and a name, and a minimum severity in `eventSeverity`. When `eventSeverity` is not set or is `info`, all events are sent, including errors. Set to `error`, only failures are sent. The lists `inclusionList` and `exclusionList` filter on the message with regular expressions, which keeps a noisy reason out of a channel.

A `Receiver` is the inbound side. It names the objects to trigger in `spec.resources` and a Secret with a `token` key. When it is `Ready`, the controller publishes a path in `status.webhookPath`. The path is derived from a hash of the token, the name and the namespace, so it cannot be guessed. A request to `/hook/<hash>` on the `webhook-receiver` Service makes the controller annotate the listed objects with a reconcile request. With type `generic` any request to the path triggers the reconcile. With type `generic-hmac` the caller must send an `X-Signature` header that carries an HMAC of the body made with the token, and requests with a bad signature are refused.

```mermaid
flowchart LR
  K["Kustomization"] -->|"events"| N["Notification controller"]
  N -->|"Alert filters"| P["Provider"]
  P -->|"HTTP POST"| X["Chat, CI or sink"]
  H["Git host"] -->|"POST to the path"| R["Receiver"]
  R -->|"reconcile request"| S["GitRepository"]
```

The diagram shows the two directions. Outbound goes from an object through an Alert to a Provider. Inbound goes from a Git host through a Receiver to a source.

## Why a Receiver is useful

A source checks Git at its interval, which is often minutes or an hour. A Receiver replaces waiting with a push: Git calls the webhook after each push, and the source fetches at once. The interval stays as a safety net for a missed call. The Receiver only asks for a reconcile. It does not carry the change, and the source still reads Git itself, so a forged call can cause extra work at worst, not a forged deployment.

The `Service` named `webhook-receiver` is not exposed outside the cluster by default. A Git host outside the cluster needs an ingress or a load balancer in front of it.

## Delivery guarantees

The notification controller sends an event over HTTP and may retry a failed request, but it does not keep the event until the destination is back. A destination that is down loses the event. Events are not a queue. The same event can also arrive twice, for example after a controller restart. Treat a notification as a hint to look, not as the record. The record is the status of the object and the history in Git.

## Argo CD notifications

Argo CD has its own notification controller. It uses three concepts in the ConfigMap `argocd-notifications-cm`: services, which are destinations such as a chat service or a webhook, templates, which are message bodies, and triggers, which are conditions on the Application that decide when to send. An Application subscribes with an annotation of the form `notifications.argoproj.io/subscribe.<trigger>.<service>: <recipient>`. Several recipients are separated by semicolons. Default subscriptions can be set in the same ConfigMap and filtered by label.

Argo CD does not have an inbound object like the Receiver. It exposes a webhook endpoint in the API server, at `/api/webhook`, that accepts push events from Git hosts and refreshes the Applications that use the repository. A webhook secret in `argocd-secret` is used to verify the sender.

## Try it: send events to the sink

The playground has a web server named `sink` that writes each request body to its log. Create a Provider that points to it, and an Alert that sends the events of the Kustomization.

<!-- astrona:playground:renew -->

Save this as `notify-scout.yaml`:

```yaml
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Provider
metadata:
  name: probe-sink
  namespace: flux-system
spec:
  type: generic
  address: http://sink.starfleet.svc/cgi-bin/events
---
apiVersion: notification.toolkit.fluxcd.io/v1
kind: Alert
metadata:
  name: probe-events
  namespace: flux-system
spec:
  providerRef:
    name: probe-sink
  eventSeverity: info
  eventSources:
    - kind: Kustomization
      name: scout-staging
```

Apply it and check:

```sh
kubectl apply -f notify-scout.yaml
kubectl -n flux-system get provider probe-sink
kubectl -n flux-system get alert probe-events
```

Make the Kustomization produce an event by changing the staging message in Git and asking Flux to apply, then read the sink:

```sh
STAMP="$(date +%s)"
kubectl -n flux-system annotate kustomization/scout-staging --overwrite reconcile.fluxcd.io/requestedAt="$STAMP"
kubectl -n starfleet logs deploy/sink
```

Each line in the log is the JSON body of one event. If there is no line yet, the Kustomization had nothing to change. Push a new commit that changes the message of `overlays/staging/message.yaml` to the repository `http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git`, ask the `GitRepository` named `scout` and then the Kustomization to reconcile with the same annotation, and read the log again. Read the field `involvedObject` to see which object the event is about and `severity` to see the level.

## Reading why nothing arrives

When an expected notification does not arrive, check from the destination backwards. Does the destination accept the request? Does the Provider address resolve inside the cluster? Does the Alert name the right kind and name in `eventSources`? Is the severity filter hiding the event? Was an event produced at all, which means a real change happened? The controller logs of the notification controller show the send attempts and their errors.

## Common pitfalls

> [!WARNING]
> A generic Receiver has no signature check, so the secrecy of its path is the only protection. Use `generic-hmac` when the caller can sign, keep the token in a Secret that only the engine can read, and never post the webhook URL in a public place.

An Alert only matches the objects that its `eventSources` name. A wrong kind or name does not produce an error, the Alert simply never matches, so a silent Alert is more often a typo than a fault in the controller.

A notification that fires on every `info` event becomes noise and people stop reading it. Send `error` events to the channel that people watch, and keep `info` for a log or a dashboard.

Key facts:

- Events are facts about attempts, with a severity, and they can repeat.
- A Provider is a destination, an Alert selects events for it, and a Receiver accepts inbound webhooks.
- The generic Provider sends a JSON event by HTTP POST.
- A Receiver publishes `status.webhookPath` and only asks the target to reconcile.
- Argo CD uses triggers, templates and services with a subscribe annotation, and has no Receiver object.
- A notification is a hint, and the status and the history are the record.

