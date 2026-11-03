---
estimated_duration: 25m
---

# Capstone: Resume Paused Flux Pipelines

Status: UNTESTED. Built with static checks only. Never booted.

Graded capstone for section 030. Flux delivered release 1, Git moved to release 2, and then a Kustomization and a HelmRelease were suspended. The learner finds the pause, resumes both, and brings staging and production to the head of `main`.

```sh
astrona run -c sections/section-030/capstone/labs/lab-01
astrona submit -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-068-lab-030-capstone
```
