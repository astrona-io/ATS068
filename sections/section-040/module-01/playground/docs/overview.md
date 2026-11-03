# Overview: Delivery Feedback (Playground)

This is a playground, not a lab. It starts a cluster with Flux, a private Git repository and a web server that records notifications, and then waits. There is no task, no `astrona submit` and no pass or fail. Create objects, break things, run `astrona destroy`, and start over.

## What is in the environment

- A single-node `kind` cluster that runs Kubernetes 1.35. `kubectl` already points at it.
- Flux 2.9.6 in the namespace `flux-system`: the source, kustomize, Helm and notification controllers.
- A private Git repository at `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. From your machine it is `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`.
- A `GitRepository` named `scout` that checks Git once an hour, and a `Kustomization` named `scout-staging` that delivers `overlays/staging` into `starfleet-staging` with `wait: true`.
- A Secret `scout-readonly` with a read-only Git user, and the namespaces `starfleet-staging` and `starfleet-production`.
- `sink`, a small web server in the namespace `starfleet`. It accepts a POST at `http://sink.starfleet.svc/cgi-bin/events` and writes the body as one line to its log. Read it with `kubectl -n starfleet logs deploy/sink`.
- `shuttle`, a client pod with `curl`, in the namespace `starfleet`.
- No Provider, Alert or Receiver exists yet.

## Practice tasks

- Push a commit from your machine, ask the source and the Kustomization to reconcile with the annotation `reconcile.fluxcd.io/requestedAt`, and compare the revision of each object with the commit.
- Create a Provider of type `generic` and an Alert, change something in Git, and read the events in the `sink` log.
- Set `eventSeverity: error` and see which events stop arriving. Add an `exclusionList` entry and see another filter at work.
- Create a Secret with a `token` key and a Receiver for the source. Read `status.webhookPath`, then call it from `shuttle` with `curl -X POST http://webhook-receiver.flux-system.svc<path>`.
- Change the Receiver to type `generic-hmac` and see that an unsigned call no longer triggers a fetch.
- Push an image tag that does not exist and read the status, the events and the metrics of the failed Kustomization.
