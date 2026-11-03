# Git And Version Pinning With Argo CD - Playground

- **Slug:** ats-068-playground-020-01
- **Type:** Astrona playground: clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (`kindest/node:v1.35.8`) with Argo CD 3.5.4, an in-cluster Gitea (plumbing only) holding the private repository `starfleet/scout-deploy` with two release commits and the tag `v1.0.0`, a repository Secret for Argo CD, and the `shuttle` client. Port forwards: Argo CD on `https://127.0.0.1:8080`, Git on `http://127.0.0.1:3000`. Needs outbound internet for the Argo CD install manifest.

```sh
astrona run -c .
astrona destroy ats-068-playground-020-01
```

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/` | Gitea, Argo CD install, history seed and repository Secret |
| `manifests/` | Gitea Deployment and Service, the `starfleet` namespace and `shuttle` |
| `repos/scout-deploy/` | Repository content that the seed script turns into the history |
| `docs/overview.md` | What the environment contains and ideas to try |
