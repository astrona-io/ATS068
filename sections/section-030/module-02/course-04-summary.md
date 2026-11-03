---
draft: true
exam_objectives:
- Reconciliation Engines (ArgoCD, Flux, and alternatives)
---
# Summary

Flux is a set of controllers that talk through Kubernetes objects. The source controller fetches Git, a chart repository, an OCI registry or a bucket, and publishes the result as an artifact with a revision. The kustomize controller builds and applies a path from an artifact. The Helm controller installs and upgrades Helm releases from a chart. The notification controller handles events. Each object reports through conditions, and `Ready` is the one to read.

A Kustomization applies a path on an interval, prunes objects that Git no longer holds when pruning is on, can wait for health, and can depend on other Kustomizations. A HelmRelease takes a chart from a source, merges values, and runs Helm, so a Helm release record exists in the cluster. A chart that comes from Git is rebuilt for each new commit only when the reconcile strategy says so.

Flux differs from Argo CD in several ways. Flux applies on each interval and corrects drift for Kustomizations without a setting, while Argo CD needs self-heal. Flux keeps an inventory of what it applied, and Argo CD marks objects with an annotation. Flux uses real Helm releases, and Argo CD only renders charts. Flux has no built-in interface, and a person reads the objects or uses the command-line tool.

Pausing is a field on each object. A suspended Kustomization stops both new revisions and drift correction, and a suspended HelmRelease does not upgrade. A pause that nobody records is a common reason for an environment that does not follow Git. Reading the revision that was last applied and the suspend field answers most questions about a stuck delivery.

Key facts:

- The source controller makes artifacts, and the other controllers apply them.
- The revision has the form branch, at sign, hash type and commit.
- A Kustomization corrects drift at each interval unless it is suspended.
- A HelmRelease keeps a Helm release record, and Helm drift detection is a setting.
- Suspend stops reconciliation, and resume starts it again.

<!-- astrona:playground:destroy -->
