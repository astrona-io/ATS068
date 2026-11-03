# Solution

## Step 1: Find the bad commit

Clone the repository through the port forward on port 3000 and read the history:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
git log --oneline
git show HEAD
```

The newest commit is `Release 6.99.0`. The diff shows that it changes the image tag in `overlays/staging/kustomization.yaml` to `6.99.0`, which does not exist in the registry.

## Step 2: Revert it with a new commit

Create a commit that undoes the change, and push it:

```sh
git revert --no-edit HEAD
git log --oneline
git push origin main
```

`git revert` writes a new commit that applies the opposite change. The history keeps `Release 6.99.0` and gains a commit whose subject starts with `Revert`. A reset with a forced push would also restore the files, but it would remove the bad commit from the history, and the check `reverted-in-git` would fail.

Run `astrona submit`. The check `reverted-in-git` should pass.

## Step 3: Let Argo CD apply the revert

The Application follows `main` with automated sync, so it picks up the revert at the next refresh. To speed it up, ask for a hard refresh:

```sh
kubectl -n argocd annotate application scout-staging argocd.argoproj.io/refresh=hard --overwrite
kubectl -n argocd get application scout-staging
kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}'
```

When the new pods are ready, the Application is `Synced` and `Healthy` and the image is `6.14.0`. Run `astrona submit` again. All three checks should pass. Do not edit the Application: the check `application-follows-main` fails if it is pinned or if automation is off.
