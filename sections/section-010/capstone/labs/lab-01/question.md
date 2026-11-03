# Question

The `drifter` team added a new preview overlay for `scout` in the private Git repository `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` (from your machine: `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`). The overlay is `overlays/preview`. It should deliver `scout` with 3 replicas and the message `preview` to the namespace `starfleet-preview`. Nobody has delivered it yet, and `kubectl kustomize overlays/preview` fails when run on a clone of the repository.

Argo CD already has a repository Secret for this repository.

1. Find out why the overlay does not build, and fix it with a commit on branch `main`. The shared `base/` must stay exactly as it is.
2. Create an Application `scout-preview` in the namespace `argocd` for the path `overlays/preview` on branch `main`, with destination `https://kubernetes.default.svc` and namespace `starfleet-preview`. It must sync automatically with self-heal and create the namespace.
3. Make sure Argo CD reports the Application as Synced and Healthy and that `shuttle` receives the message `preview` from `scout` in `starfleet-preview`.

Check your work with `astrona submit`.
