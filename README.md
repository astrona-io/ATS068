# Tooling (ATS068)

Certified GitOps Associate (CGOA): Tooling, worth 14% of the official curriculum. This course belongs to ATP013.

Developed reading explains mechanisms, responsible components, examples and limits. Every module has a playground and a graded lab, every section has a capstone lab and a quiz, and a final domain quiz closes the course. Labs run on kind and are built untested. Technical content remains draft.

## Course Outline

| Section / module | Module | Teaching files |
| --- | --- | --- |
| 010 / 01 | Helm And Kustomize As Argo CD Rendering Inputs | How Argo CD Renders A Helm Chart; Kustomize Bases, Overlays And Argo CD; Repeatable Rendering, Secrets And Reading Errors |
| 010 / 02 | Plain Manifests, Jsonnet And Config Management Plugins | Directory Sources And Source Type Detection; Jsonnet Programs That Generate Manifests; Config Management Plugins; Choosing A Format And Keeping Output Reviewable |
| 020 / 01 | Git, Artifact Stores And Version Retrieval Contracts | Git As A State Store; Pinning Versions And Resolving Selectors; Alternative Stores, Access, Audit And Recovery |
| 020 / 02 | OCI Artifacts As A State Store | What An OCI Artifact Is; Flux OCIRepository; Publishing, Tagging And Retention; Argo CD OCI Sources And Choosing A Store |
| 030 / 01 | Argo CD As A Reconciliation Engine | Argo CD Components And The Reconciliation Loop; Sync Policy: Automated Sync, Prune And Self-Heal; Sync Order, Health And Deleting Applications |
| 030 / 02 | Flux As A Reconciliation Engine | Flux Controllers And The Source Pipeline; Kustomization And HelmRelease Objects; Comparing Argo CD And Flux: Pause, Drift And Prune |
| 030 / 03 | Argo CD Projects, ApplicationSets And Multiple Sources | AppProject Guardrails; ApplicationSet Generators And Templates; Multiple Sources And Values From Git; App Of Apps, Generator Choices And Troubleshooting |
| 040 / 01 | Delivery Feedback Between CI, The Engine, Notifications And Observability | Build Artifacts And The CI To Engine Contract; Notifications: Events, Providers, Alerts And Receivers; Observing Delivery: Status, Events And Metrics |
| 040 / 02 | Image Updates: CI Commits And Automation | CI Commits Versus Registry-Driven Updates; Flux ImageRepository And ImagePolicy; ImageUpdateAutomation, Setters And Commits; Argo CD Image Updater, Safety And Choosing A Tool |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [question-bank documentation](ASSESSMENTS.md) and [contribution instructions](CONTRIBUTING.md). No runtime execution is claimed; labs and playgrounds are untested.
