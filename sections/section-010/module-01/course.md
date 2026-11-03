---
draft: true
exam_objectives:
- Manifest Format and Packaging
---
# Helm And Kustomize As Argo CD Rendering Inputs

<!-- astrona:playground -->

Argo CD does not read plain Kubernetes manifests only. It can also generate them from a Helm chart or a Kustomize directory. This module explains how that generation works, which component does it, and which settings change the result. You practise in a playground that has Argo CD, a Git server and a repository with both kinds of input.

## Learning Goals

- Explain what a Helm chart, a values file and a release name are, and how Argo CD uses Helm only to render manifests.
- Interpret how values, parameters and the release name change the generated Deployment and Service.
- Explain Kustomize bases, overlays, patches and image overrides, and set them in an Application.
- Judge whether rendering is repeatable, and where secrets must not appear.

## Before You Start

You need the playground that opens with this module. It has Argo CD 3.5.4, a private Git repository named `scout-deploy`, and a client pod named `shuttle`. The `argocd` and `helm` command-line tools are optional.

## Reading Order

The first part covers Helm charts and how Argo CD renders them. The second part covers Kustomize bases and overlays. The third part covers repeatable rendering, secrets and how to read a rendering error. A graded lab follows the second part, and the summary closes the module.
