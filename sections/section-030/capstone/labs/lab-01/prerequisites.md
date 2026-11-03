# Prerequisites

- `kubectl` 1.35. The `flux` command-line tool is optional.
- Flux 2.9.6 in the namespace `flux-system`, the private Git repository `starfleet/scout-deploy` and the read-only Secret `scout-readonly`. The lab creates them.
- The Flux objects `scout` (GitRepository), `scout-staging` (Kustomization) and `scout-production` (HelmRelease). Both deliveries are suspended. The lab creates them.
- The `shuttle` client pod in the namespace `starfleet`.
