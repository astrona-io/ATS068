---
estimated_duration: 25m
---

# Deliver Manifests From An OCI Artifact With Flux

Status: UNTESTED. Built with static checks only (`astrona validate`, `bash -n`, YAML parsing). Never booted.

Graded lab. Flux and an in-cluster OCI registry with two versions of the `scout` manifests exist. The learner creates an `OCIRepository` that follows a semantic version range, and a `Kustomization` that applies the artifact.

```sh
astrona run -c sections/section-020/module-02/labs/lab-01
astrona submit -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-068-lab-020-02
```

Authors can run the reference solution with `astrona test -c sections/section-020/module-02/labs/lab-01`.
