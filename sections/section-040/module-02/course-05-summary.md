---
draft: true
exam_objectives:
- Interoperability with Notifications, Observability, and Continuous Integration Tools
---
# Summary

A new image tag must reach the engine through Git. Two designs write it. In the first, the CI job commits the tag, which is fast and carries build context but gives CI write access to the deployment repository. In the second, a component in the cluster scans the registry, applies a rule and commits the result, which keeps the write credential in one place and adds a polling delay. Many teams automate staging and review production. Mutable tags can point at different images, so tag immutability or a digest pin is needed for a trustworthy record.

Flux splits the work into three objects. An `ImageRepository` scans one image and reports a tag count and the newest tags. An `ImagePolicy` selects one tag with `semver`, `numerical` or `alphabetical` rules, optionally shaped by `filterTags`, and records `latestRef` and `observedPreviousRef`. An `ImageUpdateAutomation` clones the GitRepository, finds markers of the form `{"$imagepolicy": "namespace:name:suffix"}`, replaces the values, and commits and pushes with a configured author and message. The suffix `tag`, `name` or `digest` selects the part written. The pushed commit makes the next run a no-op, which ends the loop.

Argo CD Image Updater is a separate project. It writes either to the Application as an override or to Git. Only the Git method keeps Git as the source of truth. The choice of tool follows the engine in use.

Safe automation follows a range, limits itself to lower environments or a separate branch, keeps one writer per line, and holds a rollback by suspending the automation or changing the rule.

Key facts:

- `ImageRepository` scans. `ImagePolicy` chooses. `ImageUpdateAutomation` writes.
- The marker sits on the same line as the value it replaces.
- The GitRepository Secret must allow pushes for the automation to work.
- The image automation controller and the image reflector controller are optional Flux components.
- A revert of the bot commit does not hold while the automation is active.

<!-- astrona:playground:destroy -->
