---
estimated_duration: 25m
---

# Restrict A Project And Generate Applications With An ApplicationSet

Status: UNTESTED. Built with static checks only (`astrona validate`, `bash -n`, YAML parsing). Never booted.

Graded lab. Argo CD and a private repository with a Kustomize base and two overlays exist, and so does the repository Secret. The learner creates an `AppProject` that limits sources, destinations and cluster resources, and an `ApplicationSet` with a list generator that creates one Application per environment.

```sh
astrona run -c sections/section-030/module-03/labs/lab-01
astrona submit -c sections/section-030/module-03/labs/lab-01
astrona destroy ats-068-lab-030-03
```

Authors can run the reference solution with `astrona test -c sections/section-030/module-03/labs/lab-01`.
