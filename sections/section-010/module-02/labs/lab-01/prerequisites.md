# Prerequisites

- `kubectl` 1.35. The `argocd` command-line tool is optional.
- Argo CD 3.5.4 in the namespace `argocd`, and a repository Secret that lets it read the repository. The lab creates both.
- The private Git repository `starfleet/scout-deploy` with the folders `plain/` (plain manifests and a `drafts/` folder) and `jsonnet/` (a Jsonnet program and its library). The lab creates it.
- The `shuttle` client pod in the namespace `starfleet`. The namespaces `starfleet-staging` and `starfleet-production` do not exist yet.
