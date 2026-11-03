# Question

The `drifter` team has an Argo CD Application `scout` in the namespace `argocd`. It delivers `overlays/staging` from the branch `main` of `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` to the namespace `starfleet-staging` on `https://kubernetes.default.svc`. It has no sync policy, so nothing is delivered. A first sync attempt would also fail, because the destination namespace does not exist.

Change the existing Application so that Git alone controls staging.

1. The Application must create the destination namespace when it syncs.
2. It must sync automatically, delete objects that leave Git (prune), and revert changes made directly in the cluster (self-heal).
3. Argo CD must report the Application as Synced and Healthy, and `shuttle` must receive the message `staging` from `scout` in `starfleet-staging`.
4. A manual change in the cluster, such as scaling the Deployment to 3 replicas, must be reverted by Argo CD.

Keep the source (branch `main`, path `overlays/staging`) and the destination as they are. Do not delete the Application and do not change the repository.

Check your work with `astrona submit`. The last check scales the Deployment to 3 replicas and waits for Argo CD to revert it.
