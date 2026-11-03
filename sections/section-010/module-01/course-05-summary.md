---
draft: true
exam_objectives:
- Manifest Format and Packaging
---
# Summary

Argo CD can generate the desired Kubernetes manifests from a Helm chart or a Kustomize directory. In both cases the repo-server component renders the input, and the application controller compares the result with the cluster and applies the difference. Helm acts only as a renderer here. There is no Helm release record, and a rollback is a Git change.

A Helm chart combines templates with values. The release name, the chart defaults, value files, a values object and single parameters decide the generated names, labels and counts, and a later source overrides an earlier one. Kustomize keeps plain manifests in a base and changes them with overlays, patches, labels and image overrides. A patch whose target does not exist stops the build and shows up as a comparison error on the Application.

Rendering must give the same output for the same commit. Random values, floating chart versions and moving remote bases break that rule, and the Application then never settles. Pinned inputs and a reviewed diff keep it stable. Secret values do not belong in values files, patches or generators, because every reader of the repository can read them. A successful render proves only that manifests were produced. Acceptance by the cluster and the health of the pods are separate stages.

Key facts:

- The `helm` block and the `kustomize` block of the Application source change the rendering without a Git commit.
- `.Release.Name` comes from `helm.releaseName`, or from the Application name when it is empty.
- Argo CD tracks objects with an annotation, not with a Helm release record.
- Pin chart versions, images and remote bases, and keep secrets out of the inputs.

<!-- astrona:playground:destroy -->
