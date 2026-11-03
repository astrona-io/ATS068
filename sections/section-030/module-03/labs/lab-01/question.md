# Question

The `drifter` team in `outpost` wants one project that limits where its Applications may deploy, and one definition that creates the staging and production Applications for `scout`. Argo CD already has a repository Secret for `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. The repository has the overlays `overlays/staging` and `overlays/production`. The namespaces `starfleet-staging` and `starfleet-production` do not exist yet.

Create two objects in the namespace `argocd`.

1. An `AppProject` named `starfleet`. It allows only the repository above as a source, only the destinations `starfleet-staging` and `starfleet-production` on `https://kubernetes.default.svc`, and only the kind `Namespace` as a cluster-scoped resource, so that Argo CD can create the namespaces.
2. An `ApplicationSet` named `scout-envs` with a list generator for the environments `staging` and `production`. Each generated Application is named `scout-<environment>`, belongs to the project `starfleet`, follows the branch `main`, builds `overlays/<environment>`, deploys to `starfleet-<environment>`, syncs automatically and creates its namespace.

Both Applications must become `Synced` and `Healthy`, and a request from `shuttle` to each environment must return that environment's own message. Do not change the repository.

Check your work with `astrona submit`.
