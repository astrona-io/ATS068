# Prerequisites

- `kubectl` 1.35 and `git`. The `argocd` command-line tool is optional.
- Argo CD 3.5.4 in the namespace `argocd`, and a repository Secret that lets it read the repository. The lab creates both.
- The private Git repository `starfleet/scout-deploy` with two release commits on `main` and the tag `v1.0.0` on the first one. The lab creates it.
- The `shuttle` client pod in the namespace `starfleet`. The namespace `starfleet-staging` does not exist yet.
