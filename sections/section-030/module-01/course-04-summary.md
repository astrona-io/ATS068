---
draft: true
exam_objectives:
- Reconciliation Engines (ArgoCD, Flux, and alternatives)
---
# Summary

Argo CD splits reconciliation into components. The repo-server fetches Git and renders manifests. The application controller compares the rendered manifests with the live objects and applies the difference. The API server serves the interface, and a cache holds the repository and cluster state. The result of a comparison is a sync status, and a separate health status says whether the objects work.

A sync happens when a person starts it or when the sync policy starts it. Without a policy, an Application only reports a difference. Automated sync applies a new commit by itself. Prune adds deletion of objects that Git no longer holds. Self-heal adds the reversal of changes made directly in the cluster. Each is a separate setting and each is off by default, so a change in Git is not the same as a revert of a manual edit.

A sync applies objects in order. Sync waves order objects within a phase, and hooks run jobs before, during or after the sync. Argo CD waits for the health of one wave before it starts the next. Health is judged per kind by built-in rules, and the health of the Application is the worst health among its objects. A render that succeeds, a sync that succeeds and a healthy workload are three separate results.

Deleting an Application removes its objects only when the cascade finalizer is present. Without the finalizer the objects stay and are no longer managed. Failed syncs do not repeat for the same commit unless a retry is configured.

Key facts:

- The repo-server renders, the application controller compares and applies.
- Sync status and health status are independent.
- Automated sync, prune and self-heal are three separate settings.
- Waves and hooks give order. The cascade finalizer decides what deletion removes.
- A failed automated sync is not retried for the same commit without a retry policy.

<!-- astrona:playground:destroy -->
