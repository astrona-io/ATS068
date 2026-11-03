---
estimated_duration: 30m
---

# Capstone: Fix A Broken Overlay And Deliver It

Status: UNTESTED. Built with static checks only. Never booted.

Graded capstone for section 010. The repository has an overlay `overlays/preview` whose patch targets a Deployment name that does not exist. The learner reads the build error, fixes it in Git without touching the base, and delivers the overlay with an Application.

```sh
astrona run -c sections/section-010/capstone/labs/lab-01
astrona submit -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-068-lab-010-capstone
```
