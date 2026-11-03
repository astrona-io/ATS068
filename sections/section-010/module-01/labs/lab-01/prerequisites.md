# Prerequisites

- `kubectl` 1.35. The `argocd` and `helm` command-line tools are optional.
- Argo CD 3.5.4 in the namespace `argocd`, and a repository Secret that lets it read the repository. The lab creates both.
- The private Git repository `starfleet/scout-deploy` with a Kustomize base, the overlays `staging` and `production`, and a Helm chart in `chart/`. The lab creates it.
- The `shuttle` client pod in the namespace `starfleet`. The namespaces `starfleet-staging` and `starfleet-production` do not exist yet.
