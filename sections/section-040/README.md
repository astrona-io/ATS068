---
draft: true
exam_objectives:
- Interoperability with Notifications, Observability, and Continuous Integration Tools
---
# Interoperability with Notifications, Observability, and Continuous Integration Tools

This section covers how a GitOps engine works with the tools around it. It has two modules. The module explains the contract between CI and the engine, the notification objects in Flux and Argo CD in both directions, and the signals that show whether a delivery worked: status, events and metrics. The second module covers image updates, both by CI commit and by automation in the cluster.

The first module has three reading parts and the second has four. Each has a playground, a graded lab and a summary. A capstone lab and a knowledge check close the section.

## Learning Outcomes

- Connect CI, state stores and reconciliation without sharing unnecessary authority.
- Explain notification and observability roles in feedback.
- Reason about provenance, retries and ambiguous success signals.
- Configure Flux image automation and compare it with CI-driven updates.
