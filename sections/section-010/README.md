---
draft: true
exam_objectives:
- Manifest Format and Packaging
---
# Manifest Format and Packaging

This section covers manifest format and packaging. A GitOps tool needs the desired state as Kubernetes manifests, and teams use Helm charts and Kustomize overlays to produce those manifests from shared inputs. The section explains how Argo CD renders both, what each setting changes, and how to keep the result repeatable and free of secrets.

It has two modules. The second covers plain manifests in a directory, Jsonnet and config management plugins, and how to choose a format and keep generated output reviewable.

The first module has three reading parts and the second has four. Each has a playground, a graded lab and a summary. A capstone lab and a knowledge check close the section.

## Learning Outcomes

- Explain Helm template rendering versus the Helm release lifecycle.
- Interpret chart values, release-name and namespace interactions.
- Explain Kustomize bases, overlays and transformations.
- Evaluate deterministic output and secret exposure in generation.
- Configure directory sources, Jsonnet variables and config management plugins.
- Choose a manifest format and keep generated output reviewable.
