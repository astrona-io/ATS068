# Question

The `drifter` team delivers `scout` with Flux in the namespace `flux-system`. The `GitRepository` `scout` follows the branch `main` of `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. The Kustomization `scout-staging` applies `./overlays/staging` into `starfleet-staging`. The HelmRelease `scout-production` installs the chart `./chart` as the release `scout` into `starfleet-production`.

Release 2 is on `main` since a while: the staging message is `staging-v2` and the chart message is `chart-v2`. Neither environment shows it. Someone paused the deliveries during an incident and did not record it.

Find out why and bring both environments to the head of `main`.

1. Find the cause in the Flux objects, not in the workloads.
2. Resume both deliveries. Do not change `spec.path`, the release name or `prune: true`, and do not delete or recreate any object.
3. Make Flux apply the newest commit. `scout-staging` and `scout-production` must be `Ready`, and `scout-staging` must report the head commit of `main` as its last applied revision.
4. A request from `shuttle` must return `staging-v2` from `starfleet-staging` and `chart-v2` from `starfleet-production`.

Do not change the Deployments with `kubectl`. Check your work with `astrona submit`.
