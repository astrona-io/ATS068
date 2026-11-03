#!/usr/bin/env bash
# Grades the ApplicationSet scout-envs: a list generator with two environments and a template that uses the project starfleet.
set -u
fail() { echo "FAIL: $*"; exit 1; }
kubectl -n argocd get applicationset scout-envs >/dev/null 2>&1 || fail "no ApplicationSet scout-envs in the namespace argocd"
a() { kubectl -n argocd get applicationset scout-envs -o jsonpath="$1" 2>/dev/null; }
[[ "$(a '{.spec.generators[0].list.elements[*].env}')" =~ staging && "$(a '{.spec.generators[0].list.elements[*].env}')" =~ production ]] || fail "the list generator must have the elements staging and production"
[[ "$(a '{.spec.template.spec.project}')" == "starfleet" ]] || fail "the template must use the project starfleet"
[[ "$(a '{.spec.template.spec.source.targetRevision}')" == "main" ]] || fail "the template must follow main"
for env in staging production; do
  app="scout-$env"
  kubectl -n argocd get application "$app" >/dev/null 2>&1 || fail "no Application $app was generated"
  owner="$(kubectl -n argocd get application "$app" -o jsonpath='{.metadata.ownerReferences[0].kind}/{.metadata.ownerReferences[0].name}' 2>/dev/null)"
  [[ "$owner" == "ApplicationSet/scout-envs" ]] || fail "Application $app is not owned by the ApplicationSet scout-envs (owner: '$owner')"
  [[ "$(kubectl -n argocd get application "$app" -o jsonpath='{.spec.source.path}')" == "overlays/$env" ]] || fail "Application $app does not use the path overlays/$env"
done
echo "PASS: ApplicationSet scout-envs generated scout-staging and scout-production in the project starfleet"
