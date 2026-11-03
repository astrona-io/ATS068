---
draft: true
exam_objectives:
- Interoperability with Notifications, Observability, and Continuous Integration Tools
---
# Image Updates: CI Commits And Automation

<!-- astrona:playground -->

A new image tag is the most common reason a GitOps repository changes. Someone, or something, must write that tag into Git or into the engine. This module explains the two ways to do it: the CI job commits the tag, or an automation in the cluster watches the registry and commits it. It covers how Flux image automation works object by object, how Argo CD Image Updater compares, and what keeps an automatic update safe. You practise in a playground with Flux and its image controllers, a Git server that Flux may push to, and a staging overlay that pins an image.

## Learning Goals

- Compare a CI-driven update with a registry-driven update on authority, delay, history and failure modes.
- Configure a Flux `ImageRepository` and `ImagePolicy` and read what they select.
- Configure an `ImageUpdateAutomation` with setter markers and explain the commit it creates.
- Describe how Argo CD Image Updater finds and writes new tags, and choose between the two tools.
- Reason about loops, rollbacks, digest pinning and the review of automatic commits.

## Before You Start

You need the playground that opens with this module. It has Flux 2.9.6 in the namespace `flux-system` with the image reflector and image automation controllers, a private Git repository `scout-deploy`, a `GitRepository` named `scout` whose Secret allows pushes, a `Kustomization` named `scout-staging` that delivers `overlays/staging`, and a client pod named `shuttle`. The staging overlay pins `ghcr.io/stefanprodan/podinfo` at `6.14.0`. The cluster needs outbound access to `ghcr.io`. The `flux` and `git` command-line tools are optional.

## Reading Order

The first part compares the two ways to update an image. The second part covers the image scanning objects in Flux. The third part covers the update automation and commits. A graded lab follows the third part. The fourth part covers Argo CD Image Updater, safety and the choice between tools. The summary closes the module.
