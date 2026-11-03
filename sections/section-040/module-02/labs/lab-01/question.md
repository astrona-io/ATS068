# Question

The `drifter` team in `outpost` pins the `scout` image in `overlays/staging/kustomization.yaml` of the repository `starfleet/scout-deploy`. The pin is `ghcr.io/stefanprodan/podinfo` at tag `6.14.0`, and the line carries the marker comment `# {"$imagepolicy": "flux-system:scout:tag"}`. Flux already delivers that overlay to the namespace `starfleet-staging` through the GitRepository `scout`, whose Secret `scout-write` allows pushes. The team wants staging to follow the newest `6.15.x` tag without a person editing the file.

Create three objects in the namespace `flux-system`, all named `scout`.

1. An `ImageRepository` that scans `ghcr.io/stefanprodan/podinfo` every minute.
2. An `ImagePolicy` that uses that repository and selects the newest tag in the semantic version range `6.15.x`.
3. An `ImageUpdateAutomation` with the GitRepository `scout` as its source. It checks out and pushes the branch `main`, updates the path `./overlays/staging` with the `Setters` strategy, and commits as the author `fluxbot` with the email `fluxbot@starfleet.local`.

The overlay in Git must end up with the selected tag, committed by `fluxbot` with the marker comment intact, and the Deployment `scout` in `starfleet-staging` must run that tag. Do not edit the repository by hand.

Check your work with `astrona submit`.
