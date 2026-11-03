# Prerequisites

- `kubectl` 1.35. The `argocd` command-line tool is optional.
- Argo CD 3.5.4 in the namespace `argocd`, and a repository Secret that lets it read the repository. The lab creates both.
- The private Git repository `starfleet/scout-deploy` with a Kustomize base and the overlays `staging` and `production`. The lab creates it.
- The Application `scout` in the namespace `argocd`, with no sync policy. The lab creates it.
- The `shuttle` client pod in the namespace `starfleet`. The namespace `starfleet-staging` does not exist yet.
