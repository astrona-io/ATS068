# Prerequisites

- `kubectl` 1.35. The `flux` and `helm` command-line tools are optional.
- Flux 2.9.6 in the namespace `flux-system`. The lab installs it.
- The private Git repository `starfleet/scout-deploy` with a Helm chart in `chart/`, and the Secret `scout-readonly` with a read-only user. The lab creates both.
- The namespace `starfleet-staging` and the `shuttle` client pod in the namespace `starfleet`.
- No Flux source and no HelmRelease exist yet.
