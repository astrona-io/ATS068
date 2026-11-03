---
draft: true
exam_objectives:
- Manifest Format and Packaging
---
# Summary

Argo CD reads desired state in more forms than Helm and Kustomize. The repo-server looks at the path of the source and chooses Helm when it finds a `Chart.yaml`, Kustomize when it finds a `kustomization.yaml`, and the Directory type otherwise. A tool block in the Application can force a type.

A directory source reads the `.yaml`, `.yml`, `.json` and `.jsonnet` files of the path. It does not read sub-directories unless `recurse` is true, and the `include` and `exclude` patterns decide which files count. A plain directory shows reviewers the exact objects, but it has no way to reuse a shape across environments.

Jsonnet generates manifests from a program and a library. Argo CD evaluates each `.jsonnet` file, passes external variables and top-level arguments from the Application, and applies the objects the program returns. The language cannot read the network or the clock, so the output depends only on the commit and the variables. A config management plugin runs any tool in a sidecar of the repo-server and must print manifests on standard output. It gives the most freedom and the least guarantee, and every plugin adds code to a shared component.

The choice of format is a trade between reuse and reviewability. The least powerful format that removes the duplication is usually the best. Committing rendered manifests gives reviewers the exact objects whichever format produced them.

Key facts:

- Source type detection order is Helm, then Kustomize, then Directory.
- `directory.recurse`, `directory.include` and `directory.exclude` select the files of a directory source.
- `directory.jsonnet.extVars` values are strings, and `tlas` feed top-level arguments.
- A plugin receives Application `env` entries as `ARGOCD_ENV_` variables.
- Render with the same tool versions that the Argo CD repo-server uses.

<!-- astrona:playground:destroy -->
