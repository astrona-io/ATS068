# Solution

## Step 1: Scan the image and choose a tag

The `ImageRepository` lists the tags of one image. The `ImagePolicy` picks one tag from that list with a rule. Neither object changes anything yet; they only produce a result in their status.

Save this as `image-scout.yaml`:

```yaml
apiVersion: image.toolkit.fluxcd.io/v1
kind: ImageRepository
metadata:
  name: scout
  namespace: flux-system
spec:
  image: ghcr.io/stefanprodan/podinfo
  interval: 1m
---
apiVersion: image.toolkit.fluxcd.io/v1
kind: ImagePolicy
metadata:
  name: scout
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: scout
  policy:
    semver:
      range: 6.15.x
```

Apply it:

```sh
kubectl apply -f image-scout.yaml
```

Then check the result:

```sh
kubectl -n flux-system get imagerepository scout
kubectl -n flux-system get imagepolicy scout -o jsonpath='{.status.latestRef}'
```

The repository reports how many tags it found, and the policy shows the tag it selected. Run `astrona submit`. The check for the policy should pass.

## Step 2: Let Flux commit the tag

The `ImageUpdateAutomation` reads the files of the GitRepository, finds the marker comments, replaces the value with the tag that the policy selected, commits, and pushes. The marker `flux-system:scout:tag` names the namespace, the policy and the part of the result to write. Here `tag` writes only the tag.

Save this as `automation-scout.yaml`:

```yaml
apiVersion: image.toolkit.fluxcd.io/v1
kind: ImageUpdateAutomation
metadata:
  name: scout
  namespace: flux-system
spec:
  interval: 1m
  sourceRef:
    kind: GitRepository
    name: scout
  git:
    checkout:
      ref:
        branch: main
    commit:
      author:
        name: fluxbot
        email: fluxbot@starfleet.local
      messageTemplate: 'Update image to {{range .Changed.Changes}}{{.NewValue}}{{end}}'
    push:
      branch: main
  update:
    path: ./overlays/staging
    strategy: Setters
```

Apply it:

```sh
kubectl apply -f automation-scout.yaml
```

Then check the result:

```sh
kubectl -n flux-system get imageupdateautomation scout
kubectl -n flux-system get kustomization scout-staging
kubectl -n starfleet-staging get deploy scout -o jsonpath='{.spec.template.spec.containers[0].image}'
```

After a minute or two the automation reports the commit it pushed, the GitRepository fetches it, the Kustomization applies it, and the Deployment runs the new tag. Run `astrona submit` again. All three checks should pass. If the automation reports an authentication error, the Secret of the GitRepository must allow pushes, and the branch in the automation must match the branch in the GitRepository.
