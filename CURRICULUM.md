# Curriculum Coverage

Exam: Certified GitOps Associate (CGOA). Domain: Tooling (14%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-gitops-associate-cgoa/) were checked on 2026-10-11. Teaching structure is independently authored and does not add official requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Manifest Format and Packaging | 1 |
| 020 | State Store Systems (Git and alternatives) | 1 |
| 030 | Reconciliation Engines (ArgoCD, Flux, and alternatives) | 2 |
| 040 | Interoperability with Notifications, Observability, and Continuous Integration Tools | 1 |

| Section / module | Module | Teaching files |
| --- | --- | --- |
| 010 / 01 | Helm And Kustomize As Argo CD Rendering Inputs | How Argo CD Renders A Helm Chart; Kustomize Bases, Overlays And Argo CD; Repeatable Rendering, Secrets And Reading Errors |
| 020 / 01 | Git, Artifact Stores And Version Retrieval Contracts | Git As A State Store; Pinning Versions And Resolving Selectors; Alternative Stores, Access, Audit And Recovery |
| 030 / 01 | Argo CD As A Reconciliation Engine | Argo CD Components And The Reconciliation Loop; Sync Policy: Automated Sync, Prune And Self-Heal; Sync Order, Health And Deleting Applications |
| 030 / 02 | Flux As A Reconciliation Engine | Flux Controllers And The Source Pipeline; Kustomization And HelmRelease Objects; Comparing Argo CD And Flux: Pause, Drift And Prune |
| 040 / 01 | Delivery Feedback Between CI, The Engine, Notifications And Observability | Build Artifacts And The CI To Engine Contract; Notifications: Events, Providers, Alerts And Receivers; Observing Delivery: Status, Events And Metrics |

AUTHORING.yaml records measurable goals and adaptation sources. Every objective retains its section ID. All technical readings remain draft. Every module has a playground and a graded lab, every section has a capstone lab and a knowledge check, and a final domain quiz closes the course. All labs and playgrounds are built untested: they pass static checks only and have never been booted.
