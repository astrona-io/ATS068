---
draft: true
exam_objectives:
- State Store Systems (Git and alternatives)
---
# Git, Artifact Stores And Version Retrieval Contracts

State-store tooling supplies authoritative desired versions to management agents. Git is common, but alternatives can be suitable when their contracts meet the same operational needs. The evaluation should consider content identity, immutable versions, controlled retrieval, audit and retention. A convenient download endpoint alone is not enough if it overwrites history without identifying what changed.

Git stores versioned content and relationships between commits. Hosting services can add review workflows, access controls and protected references. Those hosting policies are separate from Git's content model. A repository can have history while still allowing unauthorized changes to the reference an agent follows. Tool evaluation should identify the complete path from proposal to selected version.

Artifact stores can hold declarative bundles identified by content digest or controlled version references. OCI-based sources are one example where supported by an engine. A bundle can package several resources and associated metadata. The agent needs a supported source implementation and an understood selection policy. Not every registry or artifact format supplies the same review and history experience as Git.

Mutable selectors require resolved identity. A branch, tag or channel can be useful for selecting approved content, but its meaning can change. Recording the commit or digest actually obtained lets operators connect feedback to a concrete version. A status saying only latest is insufficient when the selector changed during an incident or between environments.

Consider a configuration bundle promoted through an artifact registry. If development and production both refer to the same digest, their declaration content is identified consistently. Environment-specific inputs can still differ, and external references can remain mutable. The digest narrows one uncertainty without proving that every dependency or resulting behavior is identical.

Retention affects recovery. A digest can remain in an audit record after the corresponding artifact has been removed. An old Git revision can reference a deleted image. Recovery requires both identified intent and available dependencies. The store's cleanup policy should align with the versions the organization expects to replay or investigate.

Verification can support trust where the engine and artifact model provide it. A signature or provenance record can establish a claim under a chosen signer and policy. It does not prove that every declared permission is appropriate or that the software has no vulnerability. Review should distinguish content integrity, approved origin and operational safety rather than collapse them into one trusted label.

Access roles also matter. Agents often need reading access, while promotion or image-update automation may need a narrow write role. Giving every source consumer permission to replace authoritative versions increases risk. Audit should identify who changed selected references and which review or policy accepted the change.

Failure modes include unavailable stores, expired credentials, missing artifacts and incompatible source formats. The agent should report the boundary it could not satisfy. Falling back silently to unrelated content makes the system harder to trust. A retained earlier version can be a deliberate behavior, but status should make clear which version is being evaluated.

A sound comparison asks whether the store supports independent retrieval after a missed event, stable content identity and controlled change history. That lets students assess Git and alternatives through observable contracts instead of assuming that only one tool name can implement the management model.

## Common pitfalls

> [!WARNING]
> A mutable selector is not content identity, and an audit record is not proof that content remains available. Signatures establish particular trust claims rather than universal safety. Evaluate retention, permissions and engine support when choosing a state store.
