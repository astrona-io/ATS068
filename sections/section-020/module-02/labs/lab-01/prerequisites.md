# Prerequisites

- `kubectl` 1.35. The `flux` command-line tool is optional.
- Flux 2.9.6 in the namespace `flux-system`. The lab installs it.
- A plain-HTTP OCI registry at `registry.registry.svc:5000` with the repository `scout-manifests` and the tags `1.0.0` and `1.1.0`. The lab creates it and pushes both artifacts.
- The `shuttle` client pod in the namespace `starfleet`, and the namespaces `starfleet-staging` and `starfleet-production`.
