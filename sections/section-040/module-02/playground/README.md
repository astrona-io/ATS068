# Image Update Automation - Playground

- **Slug:** ats-068-playground-040-02
- **Type:** Astrona playground: clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (`kindest/node:v1.35.8`) with Flux 2.9.6 and its image controllers, an in-cluster Gitea (plumbing only) holding the private repository `starfleet/scout-deploy`, a `GitRepository` that can push and a `Kustomization` that deliver the staging overlay, which pins podinfo 6.14.0 with a setter marker, a `sink` web server (busybox httpd with a CGI script) that logs every POST body, and the `shuttle` client. Port forward: Git on `http://127.0.0.1:3000`. Needs outbound internet for the Flux install manifest.

```sh
astrona run -c .
astrona destroy ats-068-playground-040-02
```

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/` | Gitea, Flux install, repository seed, write Secret, Flux objects |
| `manifests/` | Gitea, the `starfleet` namespace, `shuttle` and `sink` |
| `repos/scout-deploy/` | Repository content: Kustomize base, overlays, Helm chart |
| `docs/overview.md` | What the environment contains and ideas to try |
