---
draft: true
exam_objectives:
- Interoperability with Notifications, Observability, and Continuous Integration Tools
---
# Summary

CI builds and checks an artifact, and the desired state in Git names it. The engine reads Git and makes the cluster match. Git is the single place where the desired state changes, whether a CI job or image automation makes the commit. Each tool holds only the access it needs: CI writes to the registry and at most to one path in Git, and the engine reads Git and manages the cluster. A digest identifies content, a tag can be moved, and a green CI run says only that the pipeline steps worked.

Notifications run in two directions. Outbound, events from the controllers pass through an Alert to a Provider and reach chat, a ticket system or a CI job as an HTTP request. Inbound, a Receiver accepts a webhook from a Git host and asks a source to fetch at once, without carrying the change. Events describe attempts, can repeat, and can be lost, so a notification is a hint to look and not the record. Argo CD offers the same outbound function through triggers, templates and services with a subscribe annotation, and takes inbound Git webhooks at its API server.

Observability has three sources. Status shows the present, events show what happened recently, and metrics show trends and drive alert rules. Applied and attempted revisions, the sync and health fields, and the state of the workload are separate facts. Each signal has its own delay, and each can mean less than it seems to: a ready delivery that did not wait, a synced application that crash loops, a quiet channel that is a broken path.

Key facts:

- CI produces the artifact. The engine applies what Git names.
- Give each tool the narrowest access it needs.
- Provider, Alert and Receiver cover outbound and inbound notification in Flux.
- Events repeat and expire. Status and Git history are the record.
- Read revision, health and a real request together before calling a release done.

<!-- astrona:playground:destroy -->
