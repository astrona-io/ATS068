# Solution

## Step 1: Create the project

An `AppProject` limits what its Applications may do. `sourceRepos` lists the Git repositories they may read. `destinations` lists the cluster and namespace pairs they may deploy to. `clusterResourceWhitelist` lists the cluster-scoped kinds they may create. A Namespace is cluster-scoped, so the project must allow it for `CreateNamespace=true` to work.

Save this as `appproject-starfleet.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: starfleet
  namespace: argocd
spec:
  description: Applications of the drifter team
  sourceRepos:
    - http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  destinations:
    - server: https://kubernetes.default.svc
      namespace: starfleet-staging
    - server: https://kubernetes.default.svc
      namespace: starfleet-production
  clusterResourceWhitelist:
    - group: ""
      kind: Namespace
```

Apply it:

```sh
kubectl apply -f appproject-starfleet.yaml
```

Then check the result:

```sh
kubectl -n argocd get appproject starfleet
```

Run `astrona submit`. The check for the project should pass.

## Step 2: Create the ApplicationSet

The ApplicationSet controller reads the generator and renders the template once per element. The placeholders `{{env}}` and `{{namespace}}` take the values of each element. The controller creates and owns the Applications, and it removes them if the element disappears.

Save this as `applicationset-scout-envs.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: scout-envs
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - env: staging
            namespace: starfleet-staging
          - env: production
            namespace: starfleet-production
  template:
    metadata:
      name: 'scout-{{env}}'
    spec:
      project: starfleet
      source:
        repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
        targetRevision: main
        path: 'overlays/{{env}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{namespace}}'
      syncPolicy:
        automated: {}
        syncOptions:
          - CreateNamespace=true
```

Apply it:

```sh
kubectl apply -f applicationset-scout-envs.yaml
```

Then check the result:

```sh
kubectl -n argocd get applicationset scout-envs
kubectl -n argocd get applications
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-production
```

Two Applications, `scout-staging` and `scout-production`, appear. Each answers with its own message. Run `astrona submit` again. All three checks should pass. If an Application shows a permission error about a namespace or a kind, compare the `destinations` and the `clusterResourceWhitelist` of the project with what the Application asks for.
