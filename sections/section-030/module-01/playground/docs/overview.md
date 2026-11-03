# Overview: Argo CD Reconciliation (Playground)

This is a playground, not a lab. It starts a cluster with Argo CD and a private Git repository and then waits. There is no task, no `astrona submit` and no pass or fail. Create Applications, change sync policies, break things, run `astrona destroy`, and start over.

## What is in the environment

- A single-node `kind` cluster that runs Kubernetes 1.35. `kubectl` already points at it.
- Argo CD 3.5.4 in the namespace `argocd`, reachable on `https://127.0.0.1:8080`. The user is `admin`. The password is in the Secret `argocd-initial-admin-secret`. Dex and the notifications controller are scaled to zero.
- A private Git repository at `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. From your machine it is `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`.
- The repository holds a Kustomize base for `scout`, the overlays `overlays/staging` and `overlays/production`, and a Helm chart in `chart/`.
- A repository Secret in the namespace `argocd`, so Argo CD can already read the repository.
- `shuttle`, a client pod with `curl`, in the namespace `starfleet`.
- No `Application` exists, and the namespaces `starfleet-staging` and `starfleet-production` do not exist.

## Helper

Paste this once in each new terminal. `ask_scout` sends one request from `shuttle` to the `scout` Service in the namespace you name and prints the version and the message.

```sh
ask_scout() {
  kubectl -n starfleet exec deploy/shuttle -- curl -s "http://scout.$1" | grep -E '"(version|message)"'
}
```

## Practice tasks

- Create an Application with no sync policy and read `OutOfSync` and `Missing`. Start the sync by writing an operation into the Application.
- Turn on automated sync, then prune, then self-heal, one at a time. After each, scale the Deployment and push a change to Git, and note which one reacts.
- Remove a manifest from the overlay in a clone, push, and compare the Application with and without `prune: true`.
- Add the annotation `argocd.argoproj.io/sync-wave` to the Service and read the order in `status.operationState.syncResult`.
- Delete an Application with and without the finalizer `resources-finalizer.argocd.argoproj.io` and compare what stays in the namespace.
