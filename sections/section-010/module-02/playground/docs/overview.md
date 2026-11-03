# Overview: Plain Manifests And Jsonnet With Argo CD (Playground)

This is a playground, not a lab. It starts a cluster with Argo CD and a private Git repository and then waits. There is no task, no `astrona submit` and no pass or fail. Create Applications, break them, run `astrona destroy`, and start over.

## What is in the environment

- A single-node `kind` cluster that runs Kubernetes 1.35. `kubectl` already points at it.
- Argo CD 3.5.4 in the namespace `argocd`, reachable on `https://127.0.0.1:8080`. The user is `admin`. The password is in the Secret `argocd-initial-admin-secret`. Dex and the notifications controller are scaled to zero.
- A private Git repository at `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. From your machine it is `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`.
- The repository also holds `plain/` (plain manifests: `scout.yaml`, `extra/notes.yaml`, `drafts/draft.yaml` and a text file `notes.txt`) and `jsonnet/` (the program `scout.jsonnet` and the library `lib.libsonnet`, which read the external variables `replicas` and `message`). It further holds a Kustomize base for `scout` (podinfo, container port `9898`, Service port `80`), the overlays `overlays/staging` and `overlays/production`, and a Helm chart in `chart/` with the values `replicaCount`, `image.repository`, `image.tag` and `message`.
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

- Create an Application for `plain` without any `directory` block. Read the objects it creates and find out why `scout-notes` is missing. Then add `directory.recurse: true`.
- Add `directory.exclude: 'drafts/*'` and confirm that `scout-draft` is never created. Then change it to `directory.include: '*.yaml'` and read what changes.
- Create an Application for `jsonnet` with the external variables `replicas` and `message`. Remove one variable and read the condition that Argo CD writes on the Application.
- Change the value of `message` in `extVars` with `kubectl edit` and see how fast the Deployment changes. Nothing changed in Git.
- Run `kubectl -n argocd get cm argocd-cm -o yaml` and look for `kustomize.buildOptions`, `resource.customizations` and plugin settings. Note which of them exist by default.
