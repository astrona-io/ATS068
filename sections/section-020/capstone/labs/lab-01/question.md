# Question

The `drifter` team delivers `scout` to staging with the Argo CD Application `scout-staging`. It follows the branch `main` of the private repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`), path `overlays/staging`, with automated sync, prune and self-heal.

Someone pushed the commit `Release 6.99.0` to `main`. It sets an image tag that does not exist, so the new pods cannot start. Before that commit, staging ran the image `ghcr.io/stefanprodan/podinfo:6.14.0`.

Restore staging.

1. Recover in Git, not in the cluster. Add a revert commit on `main` that undoes `Release 6.99.0`. The commit `Release 6.99.0` must stay in the history. Do not reset, rebase or force-push.
2. Do not change the Application. It must keep following `main` with automated prune and self-heal.
3. Wait until Argo CD reports `scout-staging` as Synced and Healthy and `scout` runs `6.14.0` again.

Check your work with `astrona submit`.
