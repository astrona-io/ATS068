# Prerequisites

- `kubectl` 1.35 and `git`. The `flux` command-line tool is optional.
- Flux 2.9.6 in the namespace `flux-system`, the private Git repository `starfleet/scout-deploy` and the read-only Secret `scout-readonly`. The lab creates them.
- The `GitRepository` `scout`, the `Kustomization` `scout-staging` (with `wait: true`) and a `Provider` named `sink`. The lab creates them.
- The `sink` web server and the `shuttle` client pod in the namespace `starfleet`.
- Git access to the repository from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`.
