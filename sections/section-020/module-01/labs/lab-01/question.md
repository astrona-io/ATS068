# Question

The `drifter` team runs `scout` in staging from the private Git repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`). Release 1.0.0 is marked with the tag `v1.0.0`. The branch `main` already holds the newer release 1.1.0, which the team has not approved for staging. Argo CD already has a repository Secret for this repository. No Application exists.

Create an Application `scout-release` in the namespace `argocd` that delivers release 1.0.0 and cannot move when `main` or the tag changes.

- Source path `overlays/staging`, destination `https://kubernetes.default.svc`, namespace `starfleet-staging`.
- `targetRevision` must be the full 40-character commit ID that the tag `v1.0.0` points at, not a branch name or a tag name.
- It must sync automatically and create the destination namespace.
- Do not change the repository, and do not move the tag.

Check your work with `astrona submit`. The checks read the Application definition, the repository and the live cluster, and they send a request from `shuttle`.
