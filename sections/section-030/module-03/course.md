---
draft: true
exam_objectives:
- Reconciliation Engines (ArgoCD, Flux, and alternatives)
---
# Argo CD Projects, ApplicationSets And Multiple Sources

<!-- astrona:playground -->

One Application is easy to read. A team with ten services and three environments has thirty, and someone must decide which of them may deploy where. This module explains the three Argo CD features that handle that: the `AppProject`, which limits what Applications may do, the `ApplicationSet`, which generates Applications from a template, and multiple sources, which let one Application combine a chart and its values from different places. You practise in a playground with Argo CD, a Git server and a repository with two overlays.

## Learning Goals

- Describe what an `AppProject` restricts: source repositories, destinations, cluster-scoped and namespaced kinds, and roles.
- Explain how an `ApplicationSet` controller turns a generator and a template into Applications, and what happens when the generator output changes.
- Compare the list, Git directory and cluster generators and say which one fits a given layout.
- Combine a Helm chart and a values file from Git in one Application with `sources` and `ref`.
- Choose between an app-of-apps pattern and an ApplicationSet, and find the cause when a generated Application does not appear.

## Before You Start

You need the playground that opens with this module. It has Argo CD 3.5.4 with the ApplicationSet controller, a private Git repository `starfleet/scout-deploy` with the overlays `staging` and `production`, a repository Secret, and a client pod named `shuttle`. The `argocd` command-line tool is optional.

## Reading Order

The first part covers the `AppProject`. The second part covers the `ApplicationSet`. A graded lab follows the second part. The third part covers multiple sources. The fourth part covers app-of-apps, generator choices and troubleshooting. The summary closes the module.
