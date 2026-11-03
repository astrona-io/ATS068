---
estimated_duration: 20m
---

# Pin An Application To A Release Commit

Status: UNTESTED. Built with static checks only (`astrona validate`, `bash -n`, YAML parsing). Never booted.

Graded lab. Argo CD and a private repository exist. The repository has two releases and the tag `v1.0.0` on the first one. The learner pins an Application to the commit ID of the tag, so that the newer release on `main` is not delivered.

```sh
astrona run -c sections/section-020/module-01/labs/lab-01
astrona submit -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-068-lab-020-01
```

Authors can run the reference solution with `astrona test -c sections/section-020/module-01/labs/lab-01`.
