# Solution

## Step 1: Create the source

An `OCIRepository` tells the source controller which artifact to fetch. The range `1.0.x` selects the newest tag that starts with `1.0.`, so `1.1.0` is not chosen. The registry speaks plain HTTP, so the object needs `insecure: true`.

Save this as `ocirepository-scout-oci.yaml`:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: OCIRepository
metadata:
  name: scout-oci
  namespace: flux-system
spec:
  interval: 1m
  url: oci://registry.registry.svc:5000/scout-manifests
  insecure: true
  ref:
    semver: 1.0.x
```

Apply it:

```sh
kubectl apply -f ocirepository-scout-oci.yaml
```

Then check the result:

```sh
kubectl -n flux-system get ocirepository scout-oci
kubectl -n flux-system get ocirepository scout-oci -o jsonpath='{.status.artifact.revision}'
```

The revision has the form `1.0.0@sha256:` followed by the digest of the artifact. Run `astrona submit`. The check for the source should pass. If the object is not `Ready`, read the message of its `Ready` condition: a wrong `url` or a missing `insecure: true` shows up there.

## Step 2: Apply the artifact

A `Kustomization` can use an `OCIRepository` as its source in the same way as a `GitRepository`. The path `./` is the root of the unpacked artifact. The artifact has no `kustomization.yaml`, so the kustomize controller generates one for the files it finds.

Save this as `kustomization-scout-oci.yaml`:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: scout-oci
  namespace: flux-system
spec:
  interval: 1m
  path: ./
  prune: true
  targetNamespace: starfleet-staging
  sourceRef:
    kind: OCIRepository
    name: scout-oci
```

Apply it:

```sh
kubectl apply -f kustomization-scout-oci.yaml
```

Then check the result:

```sh
kubectl -n flux-system get kustomization scout-oci
kubectl -n starfleet-staging get deploy scout
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging
```

Run `astrona submit` again. All three checks should pass. The message is `oci-one` and the Deployment has one replica, because the range selected the artifact `1.0.0`. Artifact `1.1.0` exists in the registry, but the range excludes it.
