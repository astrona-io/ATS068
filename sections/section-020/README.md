---
draft: true
exam_objectives:
- State Store Systems (Git and alternatives)
---
# State Store Systems (Git and alternatives)

This section covers the state store, the place where a GitOps engine reads the desired state. Git is the usual store, but chart repositories, OCI registries and bucket stores can play the same role. The section explains how each store identifies a version, how Argo CD resolves a branch or a tag into one commit, how to pin an environment to a reviewed version, and how to recover from a bad release.

The section has two modules. The second covers OCI artifacts as a state store: their structure, the Flux OCIRepository, publishing and retention, and Argo CD OCI sources.

Each module has four reading parts, a playground, a graded lab and a summary. A capstone lab and a knowledge check close the section.

## Learning Outcomes

- Assess alternative state stores against version, access and audit needs.
- Distinguish mutable selectors from content identifiers.
- Explain retention and artifact verification in agent retrieval.
- Recover from a bad release with a new commit that keeps the history.
- Configure a Flux OCIRepository and explain tags, digests and retention for artifacts.
