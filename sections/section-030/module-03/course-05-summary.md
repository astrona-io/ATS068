---
draft: true
exam_objectives:
- Reconciliation Engines (ArgoCD, Flux, and alternatives)
---
# Summary

An `AppProject` limits what the Applications in it may do. It lists the source repositories, the destinations as pairs of cluster and namespace, and the cluster-scoped and namespaced kinds that Argo CD may apply. Argo CD checks the lists when an Application is created and again for every object during a sync. A namespace is a cluster-scoped kind, so `CreateNamespace=true` needs `Namespace` in the cluster-resource list. Roles, sync windows, orphaned-resource reports and signature keys add more control. A project controls what Argo CD applies, not what people can do in the cluster.

An `ApplicationSet` generates Applications. A generator produces parameter sets, a template renders one Application for each, and the controller creates, updates and deletes the Applications to match. The list generator holds the elements in the object, the Git directory generator makes one set per folder, and the cluster generator makes one per registered cluster. Matrix and merge combine generators. Generated Applications carry an owner reference to the ApplicationSet, and removing an element removes the Application and, by default, its workload.

An Application can read from several sources. A source with `ref` only exposes its files, and another source reads them with the `$name/` prefix, which lets a chart come from one place and its values from Git. The status then holds one revision per source.

App of apps uses a parent Application that deploys child Application files, and it allows each child to differ. An ApplicationSet fits children of the same shape and removes drift. Troubleshooting starts with the ApplicationSet status and controller logs, then the Application conditions, then the sync message.

Key facts:

- The default project allows every source, destination and kind.
- An empty `destinations` list allows nothing.
- `CreateNamespace=true` needs `Namespace` allowed as a cluster-scoped kind.
- A template name must contain a placeholder to be unique.
- Quote YAML values that begin with `{{`.
- `$values/path` reads a file from the source with `ref: values`.

<!-- astrona:playground:destroy -->
