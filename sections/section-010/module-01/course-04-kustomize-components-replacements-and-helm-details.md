---
draft: true
exam_objectives:
- Manifest Format and Packaging
---
# Kustomize Components, Replacements And Helm Details

The first three parts covered the main paths: a Helm chart with values, and a Kustomize base with overlays. Real repositories need a few more tools. This part covers Kustomize components and replacements, and the Helm options in an Argo CD Application that change how a chart is rendered. Each tool solves a problem that the basic form cannot, and each has a cost in readability.

## Components: reusable pieces of an overlay

An overlay changes a base. Sometimes two overlays need the same change, such as adding a monitoring sidecar or a set of labels. Copying the change into both overlays lets them drift. A Kustomize component holds the shared change once.

A component is a directory with a `kustomization.yaml` whose `kind` is `Component` and whose `apiVersion` is `kustomize.config.k8s.io/v1alpha1`. It can contain resources, patches and transformers. An overlay includes it in the `components` list, which is separate from `resources`.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
components:
  - ../../components/monitoring
```

Components are applied after the resources of the overlay are loaded, so a component can patch objects that come from the base. Because a component is not a complete build on its own, running `kustomize build` on its directory is not meaningful.

## Replacements: copy a value from one field to another

A common need is to keep two fields equal, for example a name that appears in a Service and in a Deployment argument. The `replacements` field reads a value from a source field of one object and writes it into target fields of other objects.

```yaml
replacements:
  - source:
      kind: ConfigMap
      name: scout-settings
      fieldPath: data.host
    targets:
      - select:
          kind: Deployment
          name: scout
        fieldPaths:
          - spec.template.spec.containers.[name=scout].env.[name=HOST].value
```

The source and the targets are selected by kind and name. The path uses dots, and a list element is selected with `[name=value]`. Replacements replace the older `vars` feature, which is deprecated. Use replacements for new work, and read them carefully in review: the link between the two fields exists only in the replacement block.

## Names, prefixes and labels

Several transformers change every object in a build. `namePrefix` and `nameSuffix` add text to every name and update the references inside the build. `namespace` sets the namespace of every namespaced object. The `labels` field adds labels, and with `includeSelectors: false` it leaves selectors untouched. That last point matters. Selectors of a Deployment cannot be changed after creation, so adding a label to selectors in an existing release makes the sync fail. The older `commonLabels` field always changes selectors, which is why `labels` is preferred.

## Helm details in an Application

An Argo CD Helm source has options that map to Helm flags.

- `releaseName` sets the name used by templates through `.Release.Name`. It defaults to the Application name.
- `valueFiles` lists value files from the repository. Later files override earlier ones.
- `values` and `valuesObject` hold inline values. Inline values are applied last, after the value files. `valuesObject` takes YAML as an object, while `values` takes a string.
- `parameters` set single values, like `--set`. `fileParameters` read a value from a file, like `--set-file`.
- `skipCrds: true` leaves out the custom resource definitions that the chart ships in its `crds` directory.
- `passCredentials: true` sends repository credentials to every host the chart references, and should stay off unless a chart repository needs it.
- `ignoreMissingValueFiles: true` lets the render continue when a listed value file is absent. Without it, a missing file is an error.
- `kubeVersion` and `apiVersions` tell the render which cluster version and API list to assume, which matters for charts that test `.Capabilities`.

## Helm hooks become Argo CD hooks

A chart can mark an object with a Helm hook annotation, such as `helm.sh/hook: pre-install`. Argo CD does not run the Helm lifecycle, so it maps the common hooks to its own: `pre-install` and `pre-upgrade` become PreSync, and `post-install` and `post-upgrade` become PostSync. The annotation `helm.sh/hook-delete-policy` maps to the Argo CD hook delete policy. Hooks such as `test` have no equivalent and are ignored. A chart that depends on release records, for example through the `lookup` function against its own release, behaves differently, because no release record exists.

## Try it: compare two renders

Run these commands in the playground:

<!-- astrona:playground:renew -->

```sh
kubectl -n argocd get applications
kubectl -n argocd get application -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.source.helm}{"\n"}{end}'
```

The second command prints the Helm settings of each Application, if any. Create an Application for the chart with `releaseName: scout-blue` and another with `releaseName: scout-green` in different namespaces, and compare the object names. Names that use `.Release.Name` change, and names that are fixed in the template do not.

## Common mistakes

- Adding a label with `commonLabels` to a live Deployment and breaking the selector.
- Reading a replacement as a coincidence and editing one of the two fields.
- Expecting `helm test` hooks to run.
- Putting the same key in a value file and in `valuesObject` and forgetting that inline values win.

## Check yourself

- Why use a component instead of copying a patch into two overlays?
- Which Helm option changes `.Release.Name`?
- What does Argo CD do with a `pre-install` hook?
