---
draft: true
exam_objectives:
- State Store Systems (Git and alternatives)
---
# Alternative Stores, Access, Audit And Recovery

Git is the usual state store, but it is not the only one. Engines can also read from chart repositories, OCI registries and bucket stores. This part compares the stores by the properties that matter for a GitOps engine, explains verification and access, and shows how to recover from a bad release by a new commit.

## What a store must provide

A store is useful for GitOps when it meets four needs. It gives stable content for a version. It lets the engine read it again after a missed event, so the engine does not depend on a push. It records who changed which version and when. It controls who may read and who may write.

Git provides content identity with commit IDs, full history with parent links, and a place for review before a change reaches the branch. The review and the access rules usually come from the Git host, for example protected branches and required reviews, and not from Git itself.

## Other stores

A Helm chart repository serves packaged charts that have a name and a version. Argo CD can use a chart version as `targetRevision`, and a range is allowed. The chart version in a repository index is only a label. Whether the content behind a version can change depends on the repository. Many repositories forbid replacing a published version, but that is a rule of the repository.

An OCI registry stores artifacts that are addressed by a repository name and either a tag or a digest. A digest is a hash of the content, written like `sha256:` followed by hexadecimal characters. A tag is a movable name, like a Git tag. Argo CD can read Helm charts and plain manifests from an OCI registry, and Flux has the `OCIRepository` source for the same purpose. Use the digest when the content must not change.

A bucket store, such as an object store, holds files under keys. Flux has a `Bucket` source for it. An object store gives no history unless versioning is switched on, and a key can be overwritten by anyone who has write access. The engine can detect a change by the checksum, but the store does not link versions to a review.

| Store | Fixed identifier | History and review |
| --- | --- | --- |
| Git | Commit ID | Full history, review through the host |
| Chart repository | Chart version, by convention | Depends on the repository |
| OCI registry | Digest | Depends on the registry |
| Bucket | Object version or checksum | Only when versioning is on |

The table shows the main difference. Git gives history and review as part of the model. The other stores give a fixed identifier, and history and review come from how the store is run.

## Verification

Verification proves a claim about content. A Git commit can be signed with a GPG or SSH key, and a host can mark it as verified. Argo CD can check GPG signatures. A project in Argo CD lists the allowed key IDs in `spec.signatureKeys`, and the Application then refuses a revision whose commit is not signed by one of them. Flux can verify signed Git commits and signed OCI artifacts. For OCI it uses a tool named cosign, which checks a signature that the registry stores next to the artifact.

A valid signature proves who signed the content and that it did not change after signing. It does not prove that the content is safe. A signed manifest can still ask for a privileged container. Review of the content is a separate control from verification of the origin.

## Access and audit

Engines need to read. They do not need to write to the store. Give an engine a read-only credential, such as a deploy token or a deploy key with no write permission. A pipeline that must write, for example to raise an image tag, gets a separate and narrow credential. Never give the engine and the people who write the same permission, because then anyone who can change the engine can also change what it reads.

Audit asks who changed the reference that an environment follows. In Git the answer is the commit history plus the host log for pushes and tag changes. A forced push or a moved tag can hide a change from the history, so protect the branches and tags that engines follow and keep the host audit log.

## How the engine reports what it read

Every engine has to say which version it obtained, and the reports differ by store. Argo CD writes the commit to `status.sync.revision`. Flux writes the revision of the artifact that it fetched into the status of the source object. For a Git source this holds the branch and the commit ID. For an OCI source it holds the tag together with the digest. The pair of a name and a fixed identifier is the useful form: the name tells a reader what was asked for, and the identifier tells the reader what was received.

An operator who investigates an incident reads that status first. If the identifier differs from the one in the change request, the store returned something else than expected. If the identifier is the expected one but the workload misbehaves, the cause is in the content or in the environment and not in retrieval.

## Choosing between stores

Choose Git when the team wants review, history and an audit trail in one place, and when the desired state is plain manifests or small charts. Choose an OCI registry when the same artifact must be promoted unchanged from one environment to the next, because the digest proves it is the same bytes. Choose a chart repository when a vendor publishes the chart and the team only supplies values. A bucket fits only when versioning and write controls are set up on purpose.

Mixed setups are common. A team may keep environment values in Git and take the application chart from a repository, and then it has two stores with two sets of access rules and two histories to protect. Each store that an engine reads is part of the trust boundary of the environment.

## Failure of the store

If the store is not reachable or the credential has expired, the engine cannot read. Argo CD then sets a condition on the Application, for example `ComparisonError`, and the message says what failed. The workloads that already run are not changed or removed, because the engine only changes the cluster when it has a new desired state. The state stays at the last result until the store answers again.

A good engine does not fall back to unrelated content. If the status shows an old commit, that is the last commit that was read, and the error shows why no newer one was read.

## Try it: recover by reverting

The repository for this module has a second release on `main`. Revert it in a local clone and see that the history keeps both commits.

<!-- astrona:playground:renew -->

Clone the repository and revert the newest commit locally. Do not push this:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
git log --oneline
git revert --no-edit HEAD
git log --oneline
git show --stat HEAD
```

The second `git log` shows a new commit on top. The commit of the second release is still in the list. The revert commit restores the files of the first release. Compare this with `git reset --hard HEAD~1` followed by a forced push. That command would remove the second release from the history of the branch. An engine that had synced the removed commit would then have a revision that the branch no longer contains, and the audit record would point at a commit that is hard to find.

## Retention

Recovery needs two things: a record of the intended state and the things that state refers to. A commit can still name an image tag that someone deleted from the registry. A digest in an audit record can outlive the artifact. If cleanup removes images or artifacts that old commits refer to, a revert restores the files but not the workload. Set the cleanup rules so that versions you expect to redeploy stay available.

Retention also applies to the store itself. A repository that is deleted, moved or rebuilt from a backup can lose commits that engines and audit records refer to. Keep a backup of the repository and test that a restore keeps the commit IDs.

## Common pitfalls

> [!WARNING]
> Do not recover by rewriting the history that engines follow. A reset with a forced push removes the evidence and can leave engines on a commit that the branch no longer holds. Revert with a new commit, give engines read-only access, and keep the images and artifacts that old versions refer to.
