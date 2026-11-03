# Overview: OCI Artifacts As A State Store (Playground)

This is a playground, not a lab. It starts a cluster with Flux, a private Git repository and an OCI registry that holds two versions of the `scout` manifests, and then waits. There is no task, no `astrona submit` and no pass or fail. Create Flux objects, break them, run `astrona destroy`, and start over.

## What is in the environment

- A single-node `kind` cluster that runs Kubernetes 1.35. `kubectl` already points at it.
- Flux 2.9.6 in the namespace `flux-system`: the source, kustomize, Helm and notification controllers. The image controllers are scaled to zero.
- An OCI registry in the namespace `registry`, reachable in the cluster as `registry.registry.svc:5000`. It speaks plain HTTP and needs no login. The repository `scout-manifests` has the tags `1.0.0` (one replica, message `oci-one`) and `1.1.0` (two replicas, message `oci-two`). Each artifact holds a Deployment and a Service named `scout`.
- A private Git repository at `http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git` with a Kustomize base, overlays and a Helm chart, to compare Git with the registry. From your machine it is `http://127.0.0.1:3000/starfleet/scout-deploy.git`, user `platform`, password `starfleet-gitops`.
- A Secret `scout-readonly` in `flux-system` for the Git repository.
- The namespaces `starfleet-staging` and `starfleet-production`.
- `shuttle`, a client pod with `curl`, in the namespace `starfleet`.
- No Flux source or Kustomization exists yet.

## Helpers

Paste these once in each new terminal. `ask_scout` sends one request from `shuttle` to the `scout` Service in the namespace you name and prints the version and the message. `registry_get` sends a request to the registry from `shuttle`.

```sh
ask_scout() {
  kubectl -n starfleet exec deploy/shuttle -- curl -s "http://scout.$1" | grep -E '"(version|message)"'
}
registry_get() {
  kubectl -n starfleet exec deploy/shuttle -- curl -s "http://registry.registry.svc:5000$1"
}
```

## Practice tasks

- Run `registry_get /v2/scout-manifests/tags/list` and read the tags. Then run `registry_get /v2/_catalog`.
- Create an `OCIRepository` with `ref.tag: 1.1.0`, then with `ref.semver: ">=1.0.0"`, and compare `status.artifact.revision` each time.
- Read the digest of a tag with `kubectl -n starfleet exec deploy/shuttle -- curl -sI -H "Accept: application/vnd.oci.image.manifest.v1+json" http://registry.registry.svc:5000/v2/scout-manifests/manifests/1.0.0` and look for the header `Docker-Content-Digest`.
- Pin an `OCIRepository` with `ref.digest` set to that digest. Check that it stays on the same content.
- Remove `insecure: true` from an `OCIRepository` and read the `Ready` message.
- Create a Kustomization that reads the artifact and another that reads the Git repository. Compare the revision strings in their statuses.
