---
estimated_duration: 25m
---

# Render A Helm Chart And A Kustomize Overlay With Argo CD

Status: UNTESTED. Built with static checks only (`astrona validate`, `bash -n`, YAML parsing). Never booted.

Graded lab. Argo CD and a private repository with a Helm chart and Kustomize overlays exist, and so does the repository Secret. The learner creates two Applications: one for the chart with a release name and values, one for an overlay with an image override.

```sh
astrona run -c sections/section-010/module-01/labs/lab-01
astrona submit -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-068-lab-010-01
```

Authors can run the reference solution with `astrona test -c sections/section-010/module-01/labs/lab-01`.
