---
draft: true
exam_objectives:
- Reconciliation Engines (ArgoCD, Flux, and alternatives)
---
# Argo CD As A Reconciliation Engine

<!-- astrona:playground -->

A reconciliation engine is the program that keeps a cluster equal to the desired state in Git. This module explains how Argo CD does that: which components do which step, what an automated sync policy changes, and how Argo CD orders and judges what it applies. You practise in a playground that has Argo CD, a Git server and a repository with an overlay to deliver.

## Learning Goals

- Name the Argo CD components and trace one refresh from Git to the cluster.
- Read the sync status, the health status and the operation state of an Application.
- Explain what automated sync, prune and self-heal each change, and which one reverts a manual change.
- Explain sync waves, hooks and health assessment, and what deleting an Application does to its objects.

## Before You Start

You need the playground that opens with this module. It has Argo CD 3.5.4, a private Git repository named `scout-deploy`, and a client pod named `shuttle`. The `argocd` command-line tool is optional.

## Reading Order

The first part covers the components and the reconciliation loop. The second part covers the sync policy. A graded lab follows the second part. The third part covers order, health and deletion. The fourth part covers diffing, ignore rules, sync options and hooks. The summary closes the module.
