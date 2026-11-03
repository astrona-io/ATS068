---
draft: true
exam_objectives:
- State Store Systems (Git and alternatives)
---
# Summary

An OCI registry can be a state store. It holds artifacts: a manifest that lists a config blob and one or more layers by digest, with annotations. A tag is a movable name for a manifest. A digest is the SHA-256 hash of the manifest and identifies the content, so a client that fetches by digest gets the same bytes every time.

Flux fetches an artifact with an `OCIRepository`. The `spec.ref` field selects a tag, a semantic version range or a digest, and the choice decides how much the cluster moves without a change in the cluster. The status records the selected revision as the tag, then `@`, then the digest. A Kustomization or HelmRelease reads the stored artifact from the source controller and never talks to the registry. Comparing the revision of the source with the last applied revision of the consumer shows whether a release has arrived.

Publishing is a pipeline job: pack a folder, push it with annotations that name the source and the commit, and add the release tags. A registry has no history and no review, so those stay in Git. Tag policies, tag immutability, push permissions and retention are part of the design. A retention rule that deletes an old artifact breaks rollbacks to it.

Argo CD reads Helm charts from OCI registries and, from version 3.1, plain manifest artifacts, with the tag or digest as the target revision. After the fetch, reconciliation is the same as for Git. Choosing between Git and a registry means comparing history, review, version identity, access, recovery and network reach. Many teams keep Git for people and use a registry for the build output that the cluster follows.

Key facts:

- A tag can move. A digest cannot.
- `OCIRepository` `spec.ref` takes `tag`, `semver`, `semverFilter` or `digest`.
- The revision string is the tag, then `@`, then the digest.
- `insecure: true` allows plain HTTP and is only for test registries.
- A retention policy can delete the version a rollback needs.

<!-- astrona:playground:destroy -->
