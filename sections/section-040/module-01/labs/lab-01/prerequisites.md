# Prerequisites

- `kubectl` 1.35. The `flux` command-line tool is optional.
- Flux 2.9.6 in the namespace `flux-system`, with the notification controller running. The lab installs it.
- The private Git repository `starfleet/scout-deploy`, a `GitRepository` named `scout` (interval one hour) and a `Kustomization` named `scout-staging`. The lab creates them.
- A web server `sink` in the namespace `starfleet` that logs every POST, and the `shuttle` client pod. The lab creates them.
- No Provider, Alert or Receiver exists yet.
