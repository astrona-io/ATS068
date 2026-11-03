---
estimated_duration: 25m
---

# Capstone: Roll Back A Bad Release With Git Revert

Status: UNTESTED. Built with static checks only. Never booted.

Graded capstone for section 020. The Application `scout-staging` follows `main` with automated sync. The newest commit on `main` is a bad release with an image tag that does not exist. The learner reverts it with a new commit, keeps the history, and waits for Argo CD to recover staging.

```sh
astrona run -c sections/section-020/capstone/labs/lab-01
astrona submit -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-068-lab-020-capstone
```
