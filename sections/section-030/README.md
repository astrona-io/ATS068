---
draft: true
exam_objectives:
- Reconciliation Engines (ArgoCD, Flux, and alternatives)
---
# Reconciliation Engines (ArgoCD, Flux, and alternatives)

This section covers the reconciliation engine, the program that keeps a cluster equal to the desired state in Git. It has three modules. The first explains Argo CD: its components, the sync policy with automated sync, prune and self-heal, and the order and health of a sync. The second explains Flux: its controllers, the Kustomization and HelmRelease objects, and how Flux differs from Argo CD in drift correction, pruning and pause. The third covers Argo CD projects, ApplicationSets and Applications with multiple sources.

Each module has four reading parts, a playground, a graded lab and a summary. A capstone lab and a knowledge check close the section.

## Learning Outcomes

- Compare reconciliation-engine responsibilities without assuming identical APIs.
- Trace source retrieval, rendering and target management.
- Identify engine-specific lifecycle and policy requirements.
- Resume and verify a paused delivery.
- Restrict Applications with a project and generate them with an ApplicationSet.
- Combine a chart and values from Git with multiple sources.
