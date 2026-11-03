# Question

The `drifter` team in `outpost` keeps two inputs for `scout` in the same Git repository, and both must be rendered by Argo CD. Argo CD already has a repository Secret for `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. The folder `plain/` holds plain manifests: `scout.yaml` at the top, `extra/notes.yaml` in a sub-directory, and a folder `drafts/` that must never reach a cluster. The folder `jsonnet/` holds a Jsonnet program `scout.jsonnet` that reads the external variables `replicas` and `message`. No Application exists.

Create two Applications in the namespace `argocd`. Both use branch `main` and the server `https://kubernetes.default.svc`.

1. `scout-plain` reads the folder `plain` and delivers it to the namespace `starfleet-staging`. It must read the sub-directories, and it must exclude the folder `drafts`.
2. `scout-jsonnet` evaluates the folder `jsonnet` with the external variables `replicas` set to `2` and `message` set to `from-jsonnet`. It delivers to the namespace `starfleet-production`.

Both Applications must sync automatically and create their destination namespace. Do not change the repository.

Check your work with `astrona submit`. The checks read the Application definitions and the live cluster, and they send a request from `shuttle`.
