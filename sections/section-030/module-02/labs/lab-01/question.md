# Question

The `drifter` team wants `scout` in staging installed as a Helm release by Flux. The chart is the directory `chart/` of the private repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` on branch `main` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`). Flux has a Secret `scout-readonly` in `flux-system` with read-only credentials for it. The namespace `starfleet-staging` exists.

Create two objects in the namespace `flux-system`.

1. A `GitRepository` named `scout` that follows the branch `main` of the repository, uses the Secret `scout-readonly`, and checks every minute.
2. A `HelmRelease` named `scout-chart` that installs the chart `./chart` from the `GitRepository` `scout`. The Helm release name is `scout` and the objects go to the namespace `starfleet-staging`. It sets the values `replicaCount: 2` and `message: from-flux`.

Both must become `Ready`. A request from `shuttle` to `scout` in `starfleet-staging` must return the message `from-flux`, and the Deployment must have two ready replicas.

Check your work with `astrona submit`.
