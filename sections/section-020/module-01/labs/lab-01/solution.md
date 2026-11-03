# Solution

## Step 1: Read the commit of the tag

List the tag through the Git port forward on port 3000 and keep the commit ID:

```sh
git ls-remote http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git refs/tags/v1.0.0
```

The line has a 40-character commit ID and the reference name. The ID is the content identity of release 1.0.0. The branch `main` points at a later commit, so using `main` would deliver release 1.1.0.

## Step 2: Create the Application with the commit ID

Save this as `application-scout-release.yaml`, and replace `COMMIT_ID` with the ID from step 1:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-release
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: COMMIT_ID
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

Apply it:

```sh
kubectl apply -f application-scout-release.yaml
```

Argo CD sends the commit ID to the repo-server, which renders the overlay from that commit. Check the result:

```sh
kubectl -n argocd get application scout-release -o jsonpath='{.status.sync.revision}'
kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}'
```

The revision is the commit ID that you set, and the image tag is `6.14.0`.

Run `astrona submit`. All three checks should pass. If `application-pinned` fails, read `targetRevision` again: a tag name or a short ID does not pass, only the full 40-character ID of the tag commit.
