---
draft: true
exam_objectives:
- Interoperability with Notifications, Observability, and Continuous Integration Tools
---
# Delivery Feedback Between CI, The Engine, Notifications And Observability

<!-- astrona:playground -->

A GitOps engine does not work alone. A continuous integration system builds the artifact, a notification system tells people what happened, and an observability system shows whether the result works. This module explains the contract between these tools: what each one may do, what it hands to the next, and which signals are reliable. You practise in a playground that has Flux, a Git server, a repository to deliver, and a small web server that records every notification it receives.

## Learning Goals

- Trace a change from a build artifact through Git and the engine to a running workload, and name who is allowed to write at each step.
- Configure outbound notifications and an inbound webhook in Flux, and describe the equivalent in Argo CD.
- Read status fields, events and metrics as separate signals, and explain why a success signal can be ambiguous.
- Reason about retries, delays and duplicate notifications.

## Before You Start

You need the playground that opens with this module. It has Flux 2.9.6 in the namespace `flux-system`, a private Git repository named `scout-deploy`, a `GitRepository` named `scout` and a `Kustomization` named `scout-staging` that deliver the staging overlay, a web server named `sink` in the namespace `starfleet` that logs every request it receives, and a client pod named `shuttle`. The `git` command is needed for one step. The `flux` command-line tool is optional, because every step uses `kubectl`.

## Reading Order

The first part covers build artifacts and the contract between CI and the engine. The second part covers notifications. A graded lab follows the second part. The third part covers status, events and metrics as observability signals. The summary closes the module.
