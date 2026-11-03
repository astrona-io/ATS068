# Get Your Machine Ready

You need the Astrona command-line tool, `astrona`, and a container engine that can run kind (Kubernetes in Docker), such as Docker or Podman. kind creates a single-node Kubernetes cluster inside a container. You also need `kubectl`, the Kubernetes command-line client, and `git`. Each playground and lab needs about 3 GiB of free memory, because it runs Argo CD or Flux next to a small Git server.

Check the tool with `astrona check`. Start an environment with `astrona run`, check a graded lab with `astrona submit`, and remove an environment with `astrona destroy` followed by the environment name. The page that opens a playground or lab shows the exact commands for it. The `helm`, `argocd` and `flux` command-line tools are optional: every task can be done with `kubectl` alone, and the pages say so where it matters.

Each environment downloads the Argo CD or Flux installation manifest and container images when it starts, so the machine needs internet access. If a start fails, run `astrona destroy` for the environment, check that the container engine is running and has enough memory, and start again.

The course uses Mermaid diagrams, a text format that the reading interface turns into drawings. If your reader does not display a diagram, the surrounding prose still explains its mechanism. The labs in this course are marked as built but not yet run end to end. If a lab check behaves differently from its task text, report the lab name and the failing check.
