---
estimated_duration: 25m
---

# Deliver Plain Manifests And Jsonnet With Argo CD

Status: UNTESTED. Built with static checks only (`astrona validate`, `bash -n`, YAML parsing). Never booted.

Graded lab. Argo CD and a private repository with a folder of plain manifests and a Jsonnet program exist, and so does the repository Secret. The learner creates two Applications: one that reads a folder recursively and excludes a sub-folder, and one that evaluates Jsonnet with external variables.

```sh
astrona run -c sections/section-010/module-02/labs/lab-01
astrona submit -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-068-lab-010-02
```

Authors can run the reference solution with `astrona test -c sections/section-010/module-02/labs/lab-01`.
