---
estimated_duration: 25m
---

# Notify And Trigger Flux With Webhooks

Status: UNTESTED. Built with static checks only (`astrona validate`, `bash -n`, YAML parsing). Never booted.

Graded lab. Flux delivers a staging overlay from a private repository and the source fetches only once an hour. The learner creates a Secret, a generic Receiver, a Provider and an Alert. The last check pushes a commit, calls the webhook from `shuttle`, and expects the source to fetch at once and an event about the Kustomization to reach the `sink` web server.

```sh
astrona run -c sections/section-040/module-01/labs/lab-01
astrona submit -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-068-lab-040-01
```

Authors can run the reference solution with `astrona test -c sections/section-040/module-01/labs/lab-01`.
