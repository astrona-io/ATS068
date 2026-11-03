# Flux Reconciliation - Playground

- **Slug:** ats-068-playground-030-02
- **Type:** Astrona playground: clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (`kindest/node:v1.35.8`) with Flux 2.9.6, an in-cluster Gitea (plumbing only) holding the private repository `starfleet/scout-deploy`, a read-only credential Secret `scout-readonly`, the namespaces `starfleet-staging` and `starfleet-production`, and the `shuttle` client. Port forward: Git on `http://127.0.0.1:3000`. Needs outbound internet for the Flux install manifest.

```sh
astrona run -c .
astrona destroy ats-068-playground-030-02
```

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/` | Gitea, Flux install, repository seed, read-only user and Secret, namespaces |
| `manifests/` | Gitea Deployment and Service, the `starfleet` namespace and `shuttle` |
| `repos/scout-deploy/` | Repository content: Kustomize base, overlays, Helm chart |
| `docs/overview.md` | What the environment contains and ideas to try |
