# Question

The `drifter` team in `outpost` wants `scout` delivered two ways from the same Git repository, and both must be rendered by Argo CD. Argo CD already has a repository Secret for `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. The repository has a Helm chart in `chart/` and Kustomize overlays in `overlays/`. No Application exists.

Create two Applications in the namespace `argocd`. Both use branch `main` and the server `https://kubernetes.default.svc`.

1. `scout-chart` renders the Helm chart in `chart/` with the release name `scout`. It sets the values `replicaCount: 2` and `message: from-chart`. It delivers to the namespace `starfleet-staging`.
2. `scout-overlay` builds the Kustomize overlay `overlays/production`. The overlay in Git uses the image tag `6.15.0`, but the Application must override the image to `ghcr.io/stefanprodan/podinfo:6.14.0` without any change in Git. It delivers to the namespace `starfleet-production`.

Both Applications must sync automatically and create their destination namespace. Do not change the repository.

Check your work with `astrona submit`. The checks read the Application definitions and the live cluster, and they send a request from `shuttle`.
