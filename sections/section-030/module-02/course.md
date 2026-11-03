---
draft: true
exam_objectives:
- Reconciliation Engines (ArgoCD, Flux, and alternatives)
---
# Flux As A Reconciliation Engine

<!-- astrona:playground -->

Flux solves the same problem as Argo CD with another design: a set of small controllers, each with its own objects, and no central user interface. This module explains the Flux controllers, the objects that connect a Git source to a delivery, and how Flux differs from Argo CD in what it stores, what it corrects and how it is paused. You practise in a playground that has Flux, a Git server and a repository with an overlay and a Helm chart.

## Learning Goals

- Name the Flux controllers and the objects each one owns, and trace a Git change through them.
- Read the revision, the conditions and the inventory that Flux records.
- Configure a Kustomization and a HelmRelease from a Git source, including pruning, waiting and dependencies.
- Compare Flux and Argo CD by stored state, drift correction, pruning and pause.

## Before You Start

You need the playground that opens with this module. It has Flux 2.9.6 in the namespace `flux-system`, a private Git repository named `scout-deploy`, a read-only credential in the Secret `scout-readonly`, the namespaces `starfleet-staging` and `starfleet-production`, and a client pod named `shuttle`. The `flux` command-line tool is optional, because every step uses `kubectl`.

## Reading Order

The first part covers the controllers and the source pipeline. The second part covers the Kustomization and HelmRelease objects. A graded lab follows the second part. The third part compares Flux with Argo CD and covers pause, drift and pruning. The fourth part covers dependencies, health checks and substitution. The summary closes the module.
