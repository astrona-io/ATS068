# Question

The `drifter` team delivers `scout` to staging with Flux. The `GitRepository` `scout` follows the branch `main` of `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. The `Kustomization` `scout-staging` in the namespace `flux-system` applies `./overlays/staging` with `wait: true`. A `Provider` named `sink` already sends events to a web server in the namespace `starfleet`, but no `Alert` uses it.

A commit named "Bump scout to 6.99.0" is on `main`. The image tag does not exist. Flux cannot finish the delivery, and nobody was told.

1. Create an `Alert` in the namespace `flux-system` that sends only error events of the `Kustomization` `scout-staging` through the Provider `sink`. Create it while the delivery still fails, so that an error event reaches the sink.
2. Record the evidence in a ConfigMap `delivery-record` in the namespace `starfleet` with two keys: `failed-revision`, the commit that Flux could not apply, and `image`, the full image reference that failed to start.
3. Fix the delivery with a new commit on `main`. Do not rewrite history and do not change the Kustomization.
4. Staging must run `ghcr.io/stefanprodan/podinfo:6.15.0`, the Kustomization must be `Ready` on the head of `main`, and a request from `shuttle` to `scout` in `starfleet-staging` must return version `6.15.0`.

Do not change `spec.wait` or `spec.path` of the Kustomization, and do not edit the Deployment with `kubectl`.

Check your work with `astrona submit`.
