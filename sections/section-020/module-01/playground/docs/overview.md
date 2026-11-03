# Overview: Git And Version Pinning With Argo CD (Playground)

This is a playground, not a lab. It starts a cluster with Argo CD and a private Git repository that has a history and a release tag, and then waits. There is no task, no `astrona submit` and no pass or fail. Create Applications, break them, run `astrona destroy`, and start over.

## What is in the environment

- A single-node `kind` cluster that runs Kubernetes 1.35. `kubectl` already points at it.
- Argo CD 3.5.4 in the namespace `argocd`, reachable on `https://127.0.0.1:8080`. The user is `admin`. The password is in the Secret `argocd-initial-admin-secret`. Dex and the notifications controller are scaled to zero.
- A private Git repository at `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. From your machine it is `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`.
- The history of the repository has two release commits. The tag `v1.0.0` points at the first one, where `overlays/staging` uses the image tag `6.14.0`. The branch `main` has a second release with `6.15.0` and the message `staging-v2`.
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

- Create one Application with `targetRevision: main` and one with the tag `v1.0.0`, in two different namespaces. Compare the images and the values of `status.sync.revision`.
- Replace the tag name with the full commit ID of the tag. Explain which part of the Application status changes and which does not.
- Clone the repository, push a new commit to `main` and watch the Application that follows `main` move. Then check that the pinned Application does not.
- Push a new tag, such as `v1.1.0`, and set `targetRevision: v1.*`. Read the commit in the status. Push `v1.2.0` and read it again after a hard refresh.
- Read `status.history` of an Application after two syncs and read the effect of `spec.revisionHistoryLimit`.
- Revert the newest commit on `main` in a clone, push it, and watch the Application that follows `main`.
