# Overview: Argo CD Projects And ApplicationSets (Playground)

This is a playground, not a lab. It starts a cluster with Argo CD and a private Git repository and then waits. There is no task, no `astrona submit` and no pass or fail. Create projects, ApplicationSets and Applications, break things, run `astrona destroy`, and start over.

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

- Read the project that exists already with `kubectl -n argocd get appproject default -o yaml` and note that it allows every repository, every destination and every kind.
- Create an `AppProject` that allows only the repository above, then create an Application in it that deploys to a namespace the project does not list. Read the condition on the Application.
- Create an `ApplicationSet` with a list generator and read the Applications it owns. Edit the element list and watch an Application appear and disappear.
- Change the policy of the ApplicationSet with `spec.syncPolicy.preserveResourcesOnDeletion: true`, delete the ApplicationSet, and see which objects stay.
- Create an ApplicationSet with a Git directory generator on `overlays/*` and compare it with the list generator.
- Create an Application with two sources: the Helm chart in `chart` and a `ref` source for the repository, and use `$values/...` in `valueFiles`.
