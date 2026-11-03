---
draft: true
exam_objectives:
- State Store Systems (Git and alternatives)
---
# OCI Artifacts As A State Store

<!-- astrona:playground -->

Git is the usual state store, but it is not the only one. A GitOps engine can also read desired state from an OCI registry, the same kind of server that holds container images. This module explains what an OCI artifact is, how Flux and Argo CD fetch one, how tags and digests identify a version, and when a registry is a better store than a Git server. You practise in a playground with Flux, an in-cluster registry and two versions of the `scout` manifests.

## Learning Goals

- Explain the parts of an OCI artifact: manifest, config, layers, media types, tags and digests.
- Configure a Flux `OCIRepository` that follows a tag, a semantic version range or a digest, and read its status.
- Explain how an artifact is published, tagged and retained, and why a tag is not immutable.
- Describe how Argo CD uses an OCI source, and compare Git and a registry on history, review, access and recovery.

## Before You Start

You need the playground that opens with this module. It has Flux 2.9.6, a registry at `registry.registry.svc:5000` with the repository `scout-manifests` (tags `1.0.0` and `1.1.0`), a private Git repository, and a client pod named `shuttle`. The `flux` command-line tool is optional.

## Reading Order

The first part covers what an OCI artifact is. The second part covers the Flux `OCIRepository` object. A graded lab follows the second part. The third part covers publishing, tagging and retention. The fourth part covers Argo CD with OCI sources and compares the two kinds of store. The summary closes the module.
