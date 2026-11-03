# Question

The `drifter` team publishes the manifests of `scout` as OCI artifacts in a registry instead of Git. The registry runs in the cluster at `registry.registry.svc:5000` and speaks plain HTTP. The repository `scout-manifests` has two tags: `1.0.0` (one replica, message `oci-one`) and `1.1.0` (two replicas, message `oci-two`). Flux is installed, and the namespace `starfleet-staging` exists. Staging must stay on the `1.0.x` line until the team approves `1.1.0`.

Create two objects in the namespace `flux-system`.

1. An `OCIRepository` named `scout-oci` for `oci://registry.registry.svc:5000/scout-manifests`. It selects the newest tag in the semantic version range `1.0.x`, accepts plain HTTP, and checks every minute.
2. A `Kustomization` named `scout-oci` that applies the root of the artifact (`./`) from that `OCIRepository` to the namespace `starfleet-staging`, with pruning on and an interval of one minute.

Both must become `Ready`. The applied revision must be `1.0.0`, and a request from `shuttle` to `scout` in `starfleet-staging` must return the message `oci-one`.

Check your work with `astrona submit`.
