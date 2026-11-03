---
estimated_duration: 20m
---

# Turn On Automated Sync With Prune And Self-Heal

Status: UNTESTED. Built with static checks only (`astrona validate`, `bash -n`, YAML parsing). Never booted.

Graded lab. Argo CD and a private repository exist, and so does an Application `scout` with no sync policy and no namespace creation. The learner edits the Application to sync automatically with prune, self-heal and namespace creation. The last check scales the Deployment by hand and expects Argo CD to revert it.

```sh
astrona run -c sections/section-030/module-01/labs/lab-01
astrona submit -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-068-lab-030-01
```

Authors can run the reference solution with `astrona test -c sections/section-030/module-01/labs/lab-01`.
