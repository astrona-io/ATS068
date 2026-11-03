# Prerequisites

- `kubectl` 1.35. The `flux` command-line tool and `git` are optional.
- Flux 2.9.6 in the namespace `flux-system`, including the image reflector and image automation controllers. The lab installs it.
- The private Git repository `starfleet/scout-deploy` and the GitRepository `scout` with a Secret that allows pushes. The lab creates them.
- Outbound internet access to `ghcr.io`, because the image reflector lists the tags of `ghcr.io/stefanprodan/podinfo`.
