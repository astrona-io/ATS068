# Overview: Image Update Automation (Playground)

This is a playground, not a lab. It starts a cluster with Flux and its image controllers, a private Git repository and a web server that records notifications, and then waits. There is no task, no `astrona submit` and no pass or fail. Create objects, break things, run `astrona destroy`, and start over.

## What is in the environment

- A single-node `kind` cluster that runs Kubernetes 1.35. `kubectl` already points at it.
- Flux 2.9.6 in the namespace `flux-system`: the source, kustomize, Helm, notification, image reflector and image automation controllers.
- A private Git repository at `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git`. From your machine it is `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`.
- A `GitRepository` named `scout` that checks Git every minute and can push, and a `Kustomization` named `scout-staging` that delivers `overlays/staging` into `starfleet-staging` with `wait: true`.
- A Secret `scout-write` with the Git user `platform`, and the namespaces `starfleet-staging` and `starfleet-production`.
- `sink`, a small web server in the namespace `starfleet`. It accepts a POST at `http://sink.starfleet.svc/cgi-bin/events` and writes the body as one line to its log. Read it with `kubectl -n starfleet logs deploy/sink`.
- `shuttle`, a client pod with `curl`, in the namespace `starfleet`.
- The file `overlays/staging/kustomization.yaml` pins `ghcr.io/stefanprodan/podinfo` at `6.14.0` and carries the marker `# {"$imagepolicy": "flux-system:scout:tag"}`.
- No ImageRepository, ImagePolicy or ImageUpdateAutomation exists yet.

## Practice tasks

- Create an `ImageRepository` for podinfo and read `status.lastScanResult` for the tag count and the latest tags.
- Create an `ImagePolicy` with `semver.range` and then with `alphabetical` or `numerical` ordering, and compare what each selects.
- Add `filterTags` with a pattern and `extract` to a policy and see how it changes the candidates.
- Create an `ImageUpdateAutomation` and read the commit it pushes with `git log` from your machine.
- Change the marker to `flux-system:scout` (whole image) and to `flux-system:scout:name`, and see what the automation writes.
- Set `spec.suspend: true` on the automation and watch the policy still move while Git stays unchanged.
- Add an `Alert` for `ImagePolicy` and `ImageUpdateAutomation` events and read them in the `sink` log.
