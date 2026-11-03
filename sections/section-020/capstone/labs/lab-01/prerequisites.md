# Prerequisites

- `kubectl` 1.35 and `git`. The `argocd` command-line tool is optional.
- Argo CD 3.5.4 in the namespace `argocd`, and a repository Secret that lets it read the repository. The lab creates both.
- The private Git repository `starfleet/scout-deploy`. Its newest commit on `main` is a bad release. The lab creates it.
- The Application `scout-staging`, which follows `main` with automated sync. The lab creates it.
- The `shuttle` client pod in the namespace `starfleet`.
