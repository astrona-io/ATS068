---
estimated_duration: 30m
---

# Capstone: Make A Failed Delivery Visible And Recover

Status: UNTESTED. Built with static checks only. Never booted.

Graded capstone for section 040. Flux delivered release 1, and then a commit with an image tag that does not exist landed on `main`. The Kustomization waits for health and fails, and no Alert exists. The learner creates an error Alert, records the failed revision and image, and fixes forward with a new commit.

```sh
astrona run -c sections/section-040/capstone/labs/lab-01
astrona submit -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-068-lab-040-capstone
```
