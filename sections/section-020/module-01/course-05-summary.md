---
draft: true
exam_objectives:
- State Store Systems (Git and alternatives)
---
# Summary

A state store must hand out the same content for the same version every time, and it must say which version it handed out. Git does this with commit IDs, which are hashes of the content and its history. A branch or a tag is only a name that points at a commit, and the name can move. Argo CD resolves the name to one commit at each refresh and records that commit as the synced revision.

A branch follows new work. A tag marks a release but can be moved. A full commit ID cannot move, so it is the only fixed pin. A semantic version range moves forward inside the range. The right choice depends on whether an environment should follow changes or stay on a reviewed version, and the status of the Application shows what it ran.

Other stores follow the same idea with other identifiers. A chart repository uses a chart version, and an OCI registry uses a tag or a digest, where the digest is the fixed identifier. Verification can prove who signed content, but it does not prove the content is safe. Access to the store decides who can change what the engine reads, so engines need read access only, and the people who change the store need review and an audit trail.

Recovery depends on history and on retention. A revert commit restores an earlier state and keeps the record of what happened, while a reset or a forced push removes the record and can leave engines on commits that no longer exist. A version that is still referenced must still be available, so cleanup rules must match the versions an organisation expects to redeploy.

Key facts:

- A commit ID names content. A branch and a tag name a commit and can move.
- Argo CD records the resolved commit, and that commit is the evidence of what ran.
- Pinning to a commit ID stops an Application from following new work.
- Recovery by a new commit keeps history. Rewriting history hides it.
- A digest or a commit ID is a stronger identifier than a tag in any store.

<!-- astrona:playground:destroy -->
