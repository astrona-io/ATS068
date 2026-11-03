# Overview: Flux Reconciliation (Playground)

This is a playground, not a lab. It starts a cluster with Flux and a private Git repository and then waits. There is no task, no `astrona submit` and no pass or fail. Create Flux objects, suspend them, break them, run `astrona destroy`, and start over.

## What is in the environment

- A single-node `kind` cluster that runs Kubernetes 1.35. `kubectl` already points at it.
- Flux 2.9.6 in the namespace `flux-system`: the source, kustomize, Helm and notification controllers. The image controllers are scaled to zero. The `flux` command-line tool is optional, because `kubectl` is enough.
- A private Git repository at `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. From your machine it is `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`.
- The repository holds a Kustomize base for `scout`, the overlays `overlays/staging` and `overlays/production`, and a Helm chart in `chart/`.
- A Secret `scout-readonly` in `flux-system` with a read-only user for the repository.
- The namespaces `starfleet-staging` and `starfleet-production`, which exist so that a Kustomization can use them.
- `shuttle`, a client pod with `curl`, in the namespace `starfleet`.
- No Flux source, Kustomization or HelmRelease exists yet.

## Helper

Paste this once in each new terminal. `ask_scout` sends one request from `shuttle` to the `scout` Service in the namespace you name and prints the version and the message.

```sh
ask_scout() {
  kubectl -n starfleet exec deploy/shuttle -- curl -s "http://scout.$1" | grep -E '"(version|message)"'
}
```

## Practice tasks

- Create a `GitRepository` and read `status.artifact.revision`. Break the Secret name and read the `Ready` message.
- Create a Kustomization for `./overlays/staging` and read `status.inventory`. Remove a manifest in a clone, push, and compare `prune: true` with `prune: false`.
- Create a HelmRelease for `./chart` with `reconcileStrategy: ChartVersion`, change `values.yaml` in Git, and see that nothing changes. Switch to `Revision` and see the upgrade.
- Find the Helm release record with `kubectl get secret -A -l owner=helm`.
- Scale a Deployment by hand and measure how long Flux needs to revert it. Then suspend the Kustomization and repeat.
- Create two Kustomizations with `dependsOn` and break the first one to see the second wait.
