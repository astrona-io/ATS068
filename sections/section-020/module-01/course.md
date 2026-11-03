---
draft: true
exam_objectives:
- State Store Systems (Git and alternatives)
---
# Git, Artifact Stores And Version Retrieval Contracts

<!-- astrona:playground -->

A GitOps tool does not keep the desired state itself. It reads the desired state from a state store, and the store must say exactly which version it hands out. This module explains how Git does that, how Argo CD turns a branch or a tag into one fixed commit, and how other stores such as chart repositories and OCI registries give the same guarantee with a digest. You practise in a playground that has Argo CD, a Git server and a repository with a history and a release tag.

## Learning Goals

- Explain what a commit ID is, and why a branch or a tag is only a movable name for one.
- Predict which commit Argo CD uses for a branch, a tag, a semantic version range and a full commit ID.
- Pin an Application to a release and read the resolved commit from its status.
- Compare Git with chart repositories, OCI registries and bucket stores by version, access and audit properties.
- Recover from a bad release without rewriting history.

## Before You Start

You need the playground that opens with this module. It has Argo CD 3.5.4, a private Git repository named `scout-deploy` with two releases in its history, and a client pod named `shuttle`. The `git` command-line tool must be installed on your machine. The `argocd` tool is optional.

## Reading Order

The first part covers how Git identifies versions and how Argo CD resolves a revision. The second part covers pinning to a fixed version and reading the history that Argo CD keeps. A graded lab follows the second part. The third part covers other stores, access, audit, retention and recovery. The summary closes the module.
