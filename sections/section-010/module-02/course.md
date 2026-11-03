---
draft: true
exam_objectives:
- Manifest Format and Packaging
---
# Plain Manifests, Jsonnet And Config Management Plugins

<!-- astrona:playground -->

Helm and Kustomize are the two best-known packaging tools, but they are not the only manifest formats a GitOps engine reads. Argo CD also reads a folder of plain YAML or JSON files, evaluates Jsonnet programs, and runs custom generators called config management plugins. This module explains how Argo CD decides which format it is looking at, which settings change what it reads, and how to choose a format that stays reviewable. You practise in a playground that has Argo CD, a Git server and a repository with plain manifests and a Jsonnet program.

## Learning Goals

- Explain how Argo CD detects the source type of a path, and read a plain directory with `recurse`, `include` and `exclude`.
- Explain what Jsonnet is, how external variables and top-level arguments reach a program, and why its output is repeatable.
- Describe how a config management plugin runs as a sidecar, what it must print, and which environment variables it receives.
- Compare plain manifests, Helm, Kustomize, Jsonnet and plugins, and pick one for a given team and risk.

## Before You Start

You need the playground that opens with this module. It has Argo CD 3.5.4, a private Git repository named `scout-deploy`, and a client pod named `shuttle`. The repository has the folders `plain/` and `jsonnet/`, next to a Kustomize base and a Helm chart that you may ignore here.

## Reading Order

The first part covers source detection and directory sources. The second part covers Jsonnet. A graded lab follows the second part. The third part covers config management plugins. The fourth part compares the formats and shows how to keep generated output reviewable. The summary closes the module.
