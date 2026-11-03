---
estimated_duration: 25m
---

# Update Images With Flux Image Automation

Status: UNTESTED. Built with static checks only (`astrona validate`, `bash -n`, YAML parsing). Never booted.

Graded lab. Flux 2.9.6 with the image controllers, a private Git repository and a GitRepository that can push exist. The staging overlay pins `ghcr.io/stefanprodan/podinfo` to 6.14.0 and carries a setter marker. The learner creates an `ImageRepository`, an `ImagePolicy` and an `ImageUpdateAutomation` so that Flux commits a newer tag to Git and rolls it out.

```sh
astrona run -c sections/section-040/module-02/labs/lab-01
astrona submit -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-068-lab-040-02
```

Authors can run the reference solution with `astrona test -c sections/section-040/module-02/labs/lab-01`.
