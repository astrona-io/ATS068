---
draft: true
exam_objectives:
- Reconciliation Engines (ArgoCD, Flux, and alternatives)
---
# App Of Apps, Generator Choices And Troubleshooting

Argo CD gives more than one way to manage many Applications. The older way is the app-of-apps pattern, and the newer way is the ApplicationSet. Both have a place. This part compares them, gives a method for choosing a generator, and lists the checks that find the cause when a generated Application does not appear or does not sync.

## The app-of-apps pattern

In the app-of-apps pattern, one parent Application points at a Git directory. The directory holds Application manifests, one file per child. Argo CD syncs the parent, which creates the children, and the application controller then syncs each child.

The parent is a normal Application with a `path` and, usually, automated sync with prune. The children are plain files that a person writes and reviews. The pattern needs no extra controller, and every child is visible as a file in Git.

## Comparing the two

| Question | App of apps | ApplicationSet |
| --- | --- | --- |
| Who writes the child? | A person, one file each | The controller, from a template |
| Adding an environment | Add a file | Add an element or a directory |
| Differences between children | Anything, per file | Only what the template allows |
| Extra controller | None | The ApplicationSet controller |
| Review in Git | Each child is a diff | A change to the template affects all |
| Drift between children | Possible, files are copied | Not possible, one template |

The table shows a trade between freedom and sameness. App of apps lets each child differ, which is useful when the children are really different services. An ApplicationSet fits children that are the same shape, such as one service in many environments or one tool on many clusters.

A common design uses both. A parent Application deploys a small set of ApplicationSet objects, so even the generators are managed from Git.

## Choosing a generator

Ask what decides how many Applications exist.

- A fixed, short list that rarely changes: use the list generator.
- A folder per environment or per service in Git: use the Git directory generator, so a new folder creates an Application.
- A config file per environment with its own values: use the Git file generator.
- One Application for every registered cluster: use the cluster generator.
- Every service in every environment, or every directory on every cluster: use the matrix generator.

Start with the simplest generator that matches the layout. A list is easy to read in a review, and it can be replaced with a Git generator later when the count grows.

## Safe rollout of template changes

A change to a template reaches every generated Application at once, and with automated sync and prune each one starts a sync. For a large set, restrict the blast radius. The `strategy` field with `type: RollingSync` updates Applications in steps by label, for example staging first and production after. The field `syncPolicy.applicationsSync: create-only` lets the controller create Applications but never change them, so a person edits each one on purpose.

## Troubleshooting a generated Application

Work from the ApplicationSet down.

1. Read the status of the ApplicationSet with `kubectl -n argocd get applicationset scout-envs -o yaml`. The `conditions` say whether the generator ran, whether the template rendered, and whether the Applications were created. An error such as `ErrorOccurred` carries a message.
2. If the Applications do not exist, read the logs of the ApplicationSet controller. A template that renders an invalid name, a generator that cannot read the repository, or a duplicate name shows up here.
3. If the Applications exist but are not synced, read the conditions on one Application. A project violation appears as `InvalidSpecError` with the rule that failed.
4. If a sync fails, read the operation message. A forbidden kind or a namespace that cannot be created is listed with the project name.
5. If the Application is `OutOfSync` and nothing happens, check the sync policy. A template without `automated` creates Applications that wait for a manual sync.

The most frequent causes are the same few: a destination not listed in the project, the kind `Namespace` missing from the cluster-resource list while `CreateNamespace=true` is set, a repository URL that differs from the one in the project or in the repository Secret, and a placeholder that is not quoted in YAML.

## Reading what the controller owns

Use label and owner queries to see the result:

```sh
kubectl -n argocd get applications -o custom-columns=NAME:.metadata.name,PROJECT:.spec.project,OWNER:.metadata.ownerReferences[0].name,SYNC:.status.sync.status,HEALTH:.status.health.status
```

The columns show each Application with its project, the ApplicationSet that owns it, and its status. An Application with an empty owner was created by hand or by an app-of-apps parent.

## Try it: break and repair a set

Save this as `appproject-narrow.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: narrow
  namespace: argocd
spec:
  sourceRepos:
    - http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  destinations:
    - server: https://kubernetes.default.svc
      namespace: starfleet-staging
```

Apply it:

```sh
kubectl apply -f appproject-narrow.yaml
```

Create an ApplicationSet with the list from the previous part, set `project: narrow`, and apply it. Then read the Applications with the command above. The staging Application cannot create its namespace, because the project has no cluster-resource entry for `Namespace`, and the production Application is outside the destinations. Read the conditions and the sync message of each, then fix the project with the missing destination and the `Namespace` kind. Both Applications sync.

## Common mistakes

- Choosing an ApplicationSet for children that really differ. The template grows conditions until it is unreadable.
- Copying app-of-apps child files and letting them drift.
- Changing a shared template without a rollout strategy.
- Looking only at the Application when the cause is in the ApplicationSet status.

## Check yourself

- Which pattern allows each child to differ, and what does it cost?
- Which generator creates an Application when a folder is added in Git?
- Where do you look first when an expected Application does not exist?
