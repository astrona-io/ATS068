---
estimated_duration: 25m
---

# Deliver A Helm Chart With Flux

Status: UNTESTED. Built with static checks only (`astrona validate`, `bash -n`, YAML parsing). Never booted.

Graded lab. Flux and a private repository with a Helm chart exist, and so does a read-only credential Secret. The learner creates a `GitRepository` and a `HelmRelease` that installs the chart as a Helm release with values.

```sh
astrona run -c sections/section-030/module-02/labs/lab-01
astrona submit -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-068-lab-030-02
```

Authors can run the reference solution with `astrona test -c sections/section-030/module-02/labs/lab-01`.
