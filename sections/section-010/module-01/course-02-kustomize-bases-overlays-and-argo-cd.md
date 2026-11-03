---
draft: true
exam_objectives:
- Manifest Format and Packaging
---
# Kustomize Bases, Overlays And Argo CD

Helm generates manifests from templates. Kustomize takes a different route: it keeps plain manifests and changes them with declared transformations. This part explains how Kustomize builds its output, how overlays specialise a base for one environment, and which Argo CD settings change a Kustomize build.

## Base, overlay and kustomization

A Kustomize directory contains a file named `kustomization.yaml`. It lists the resources to include and the changes to make. A base is a directory with ordinary manifests and a `kustomization.yaml` that lists them. It does not know about any environment.

An overlay is another directory with its own `kustomization.yaml`. It lists the base under `resources` and adds changes. The playground repository has `base/` and two overlays, `overlays/staging` and `overlays/production`. The overlays differ in namespace, replica count and message, and the base stays the same.

```mermaid
flowchart TB
  B["base/"] --> S["overlays/staging"]
  B --> P["overlays/production"]
  S --> O1["staging manifests"]
  P --> O2["production manifests"]
```

The diagram shows one base feeding two overlays, and each overlay producing its own set of manifests. The build is a function of the overlay directory: the same directory and the same base always give the same output.

## Transformations

A kustomization applies transformations after it loads the resources. The common ones are fields in `kustomization.yaml`:

- `namespace` sets the namespace on every namespaced object it builds.
- `namePrefix` and `nameSuffix` change object names and update references to them.
- `labels` adds labels, and can add them to selectors.
- `images` changes an image name, tag or digest in every pod template.
- `replicas` sets the replica count of a named workload.
- `patches` changes single fields of one object, with a strategic merge patch or a JSON patch.

A strategic merge patch is a partial manifest. Kustomize finds the target by its `kind` and `name`, and it merges the fields of the patch into the target. If no object in the build has that kind and name, the build stops with an error. The `message.yaml` file in each overlay is such a patch: it sets one environment variable in the `scout` Deployment.

Because transformations touch many objects, a broad change has a wide effect. A `namespace` field also changes the namespace of a RoleBinding subject only if the field rule covers it, and a `namePrefix` can break a reference that Kustomize does not know about. Read the built output, not only the overlay.

## Try it: build an overlay locally

The `kubectl` tool contains Kustomize, so no other tool is needed. Building shows exactly what Argo CD will see.

<!-- astrona:playground:renew -->

Clone the repository and build the production overlay:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
kubectl kustomize overlays/production
```

The output holds a Service and a Deployment. Both have the namespace `starfleet-production`, and the labels `app.kubernetes.io/part-of: starfleet` and `environment: production`. The Deployment has two replicas, the image tag `6.15.0` and the environment variable `PODINFO_UI_MESSAGE` set to `production`. Compare it with `base/deployment.yaml` to see which fields each transformation changed.

## How Argo CD builds a directory

When the `path` of an Application holds a `kustomization.yaml`, the repo-server runs `kustomize build` on that directory. Argo CD detects this by the file name. It then compares the output with the live objects, as it does for any other manifests.

The Application can change the build with the `kustomize` block of `spec.source`. These fields are the most used:

- `namePrefix` and `nameSuffix` add to the names that the overlay builds.
- `namespace` sets the namespace of the output.
- `images` is a list of image overrides, for example `ghcr.io/stefanprodan/podinfo:6.14.0`.
- `commonLabels` and `commonAnnotations` add labels and annotations to all objects.
- `replicas` overrides replica counts.

Argo CD applies these fields by editing a temporary copy of the kustomization before it builds. It does not write to Git. This is useful when the same overlay must be deployed twice with a small difference, for example a different name prefix. It is also a trap: the difference now lives in the Application, not in Git, so a reader of the repository does not see it.

## Try it: override an image in the Application

Save this as `application-scout-overlay.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-overlay
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/production
    kustomize:
      images:
        - ghcr.io/stefanprodan/podinfo:6.14.0
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-production
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

Apply it:

```sh
kubectl apply -f application-scout-overlay.yaml
```

Then check the result:

```sh
kubectl -n argocd get application scout-overlay
kubectl -n starfleet-production get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}'
```

The image is `ghcr.io/stefanprodan/podinfo:6.14.0`, although the overlay in Git says `6.15.0`. The Application override won, because Argo CD set the image on its copy before the build.

## Generated names and references

Kustomize can also generate objects. A `configMapGenerator` creates a ConfigMap whose name carries a hash of its content. When the content changes, the name changes, and Kustomize rewrites every reference to it in the build. That makes a pod template change, and Kubernetes rolls the Deployment. This only works for references that Kustomize knows, such as `envFrom` and `volumes`.

A `namePrefix` set in the Application changes names after the overlay has run. If an object in the base refers to another object by a name inside a free-text field, for example an annotation or a command-line argument, Kustomize does not update it. The reference breaks without a build error. Search the output for every place that holds a name.

## What a build error looks like

If a patch target does not exist, the repo-server cannot build the directory. Argo CD then writes a condition of type `ComparisonError` on the Application and keeps the last good state. The message holds the Kustomize error text. Read it with `kubectl -n argocd get application <name> -o yaml` and look under `status.conditions`.

A build error stops the whole Application, even if only one overlay file is wrong. Fix it in Git, push, and refresh the Application. The repo-server caches repository content for a short time, so a hard refresh can help right after a push.

In this part you saw that Kustomize builds plain manifests by applying declared transformations to a base, that Argo CD runs the build in its repo-server and can change it with the `kustomize` block, and that a wrong patch target stops the Application.

## Common pitfalls

> [!WARNING]
> A difference set in the `kustomize` block of the Application is invisible in Git. Keep environment differences in overlays unless you need the same overlay twice. Also build the overlay and read the output before you push a broad transformation such as `namePrefix` or `namespace`.
