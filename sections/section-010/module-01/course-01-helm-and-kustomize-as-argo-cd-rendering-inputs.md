---
draft: true
exam_objectives:
- Manifest Format and Packaging
---
# How Argo CD Renders A Helm Chart

A Kubernetes cluster accepts manifests: YAML objects such as a Deployment or a Service. Writing the same manifests again for every environment is slow and error-prone. Packaging tools solve this by generating the manifests from a template and a small set of inputs. This part explains Helm, the best-known packaging tool, and what Argo CD does with it.

## What a Helm chart contains

A Helm chart is a directory with a fixed layout. `Chart.yaml` holds the chart name and version. `values.yaml` holds the default input values. The `templates/` directory holds Kubernetes manifests written as Go templates, which are text files with placeholders such as `{{ .Values.replicaCount }}`.

Rendering a chart means filling the placeholders. Helm reads the templates, the default values and any overrides, and it prints plain manifests. The placeholder `.Values` gives access to the values. The placeholder `.Release.Name` gives the release name, a label that the person who installs the chart chooses.

The `scout` chart in the playground repository is small. Its Deployment uses `{{ .Release.Name }}` as the object name, `{{ .Values.replicaCount }}` for the number of replicas, and `{{ .Values.image.repository }}:{{ .Values.image.tag }}` for the image. The Service uses the same release name for its selector label `app.kubernetes.io/instance`.

```mermaid
flowchart LR
  T["templates/"] --> H["helm template"]
  V["values.yaml"] --> H
  O["overrides"] --> H
  H --> M["plain manifests"]
```

The diagram shows that the manifests are the product of templates, default values and overrides. The same chart with other overrides gives other manifests.

## Helm in two roles

Helm can work in two roles. As an installer, `helm install` renders the chart, sends the manifests to the cluster, and stores a release record in a Secret in the target namespace. Later commands such as `helm upgrade` and `helm rollback` use that record.

As a renderer, `helm template` only prints the manifests. It talks to no cluster and stores no record. Argo CD uses Helm in the second role. The repo-server component of Argo CD runs the equivalent of `helm template` on the chart in Git. The application controller then compares the output with the live objects and applies the difference.

This has consequences. The cluster has no Helm release record for an Argo CD Application, so `helm list` shows nothing for it. Argo CD tracks the generated objects itself, with a tracking annotation on each object. Helm hooks are translated into Argo CD sync hooks, and a rollback is a Git change, not a `helm rollback`.

## Where the inputs come from

Argo CD takes the chart from the `path` of the Application source. A Git source has `repoURL`, `targetRevision` and `path`. The chart's own `values.yaml` supplies the defaults. The Application then adds overrides in the `helm` block of `spec.source`:

- `releaseName` sets `.Release.Name`. If it is empty, Argo CD uses the name of the Application.
- `valueFiles` lists extra values files from the repository, applied in order.
- `valuesObject` holds values as a YAML object inside the Application.
- `values` holds the same values as a string.
- `parameters` sets single values by name, like `helm template --set`.

Argo CD renders with the values in this order: the chart's `values.yaml`, then `valueFiles`, then `valuesObject` or `values`, and then `parameters`. A later source wins over an earlier one. Knowing the order lets you predict the effect of an override before you apply it.

## Try it: render the chart yourself

The playground repository is available on your machine through a port forward on port 3000. Rendering locally shows the manifests that Argo CD will generate. This needs the `helm` tool. If you do not have it, skip to the next section and read the same result from the cluster later.

<!-- astrona:playground:renew -->

Clone the repository and render the chart with a release name and one override:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
helm template scout chart --set replicaCount=2 --set message=hello
```

Look at the Deployment in the output. Its name is `scout`, because the release name is `scout`. Its `replicas` field is `2` and the environment variable `PODINFO_UI_MESSAGE` is `hello`. Run it again with the release name `canary`. The name of the Deployment and the selector label change, because both come from `.Release.Name`.

## Try it: let Argo CD render it

Save this as `application-scout-chart.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-chart
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: chart
    helm:
      releaseName: scout
      valuesObject:
        replicaCount: 2
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
kubectl apply -f application-scout-chart.yaml
```

Then check the result:

```sh
kubectl -n argocd get application scout-chart
kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.replicas}'
kubectl -n starfleet-staging get deploy scout -o jsonpath='{.metadata.annotations}'
```

The Application reports its sync and health status. The Deployment has two replicas, which came from `valuesObject`. The annotations include `argocd.argoproj.io/tracking-id`, which names the Application that owns the object. No Helm release record exists: run `kubectl -n starfleet-staging get secret` and look for a Secret of type `helm.sh/release.v1`. You will not find one.

## Names and namespaces

Names in a chart usually come from the release name. If two Applications deploy the same chart into the same namespace with the same release name, their objects collide. Argo CD then reports that an object is already managed by another Application. Use a different release name or a different namespace.

The destination namespace of the Application is the namespace Argo CD uses for objects that do not name one. It does not rewrite a namespace that a template writes explicitly, and it does not move cluster-scoped objects. Review the rendered objects for hard-coded namespaces, bindings and storage references.

If you change the release name of a running Application, the generated names change. Argo CD creates the new objects and, with pruning on, deletes the old ones. A Service selector that mixes an old and a new label can then select no pods. Test a rename on a copy of the Application before you do it on a live one.

A Helm chart can also come from a Helm repository or an OCI registry instead of Git. In that case `repoURL` is the repository address, `chart` names the chart, and `targetRevision` is the chart version. The rendering rules above stay the same.

## What rendering does not prove

A successful render proves that the templates produced valid YAML. It does not prove that the cluster accepts the objects. The cluster can still reject a removed API version, an admission policy can still deny an object, and a pod can still fail to start. Rendering is the first stage, followed by comparison, apply and health assessment.

When something looks wrong, check the stages in order. First read the effective values and the rendered manifests. Then read the Application conditions. Then read the events of the live objects. This order separates a template mistake from a cluster problem.

In this part you saw that Argo CD uses Helm to render only, that the release name and values change the generated names and counts, and that a render can succeed while the application still fails.

## Common pitfalls

> [!WARNING]
> Do not expect `helm list` or `helm rollback` to work for an Argo CD Application. Argo CD renders the chart and applies the output itself. Also check which source of a value wins: a `parameters` entry beats `valuesObject`, which beats the chart default.
