# Solution

## Step 1: Read the plain manifests

Argo CD reads only the top level of a folder unless you ask for more. The manifest `extra/notes.yaml` sits in a sub-directory, so the Application needs `directory.recurse`. The folder `drafts/` must stay out, so it needs `directory.exclude`.

Save this as `application-scout-plain.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-plain
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: plain
    directory:
      recurse: true
      exclude: 'drafts/*'
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
kubectl apply -f application-scout-plain.yaml
```

Then check the result:

```sh
kubectl -n argocd get application scout-plain
kubectl -n starfleet-staging get deploy,configmap
```

The namespace has the Deployment `scout` and the ConfigMap `scout-notes`, and it has no ConfigMap `scout-draft`. Run `astrona submit`. The two checks for `scout-plain` should pass. If `scout-notes` is missing, `recurse` is not set. If `scout-draft` exists, the `exclude` pattern does not match the folder.

## Step 2: Evaluate the Jsonnet program

The program reads two external variables. Argo CD sets them from `directory.jsonnet.extVars`. Every external variable is a string, so the value `"2"` is quoted.

Save this as `application-scout-jsonnet.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-jsonnet
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: jsonnet
    directory:
      jsonnet:
        extVars:
          - name: replicas
            value: "2"
          - name: message
            value: from-jsonnet
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
kubectl apply -f application-scout-jsonnet.yaml
```

Then check the result:

```sh
kubectl -n starfleet-production get deploy scout -o jsonpath='{.spec.replicas}'
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-production
```

The Deployment has two replicas and the response carries the message `from-jsonnet`. Run `astrona submit` again. All four checks should pass. The repo-server component evaluates `scout.jsonnet` with the library `lib.libsonnet` from the same folder, and the application controller applies the objects it returns.
