# Question

The `drifter` team delivers `scout` to staging with Flux. The `GitRepository` `scout` in the namespace `flux-system` fetches the repository only once an hour, so a push to Git takes up to an hour to reach staging. The team also wants to see what the Kustomization `scout-staging` does. A web server `sink` in the namespace `starfleet` stands in for the team chat: it accepts a POST at `http://sink.starfleet.svc/cgi-bin/events` and writes the body to its log.

Create the following objects, all in the namespace `flux-system`.

1. A Secret `webhook-token` with the key `token` and any value you choose.
2. A `Receiver` named `scout-push` of type `generic` that uses the Secret `webhook-token` and triggers the `GitRepository` `scout`. It must become `Ready` and publish a webhook path.
3. A `Provider` named `sink` of type `generic` with the address `http://sink.starfleet.svc/cgi-bin/events`.
4. An `Alert` named `scout-events` that uses the Provider `sink` and sends the events of the `Kustomization` `scout-staging`.

Do not change the `GitRepository` interval.

Check your work with `astrona submit`. The last check pushes a new commit to Git, calls your webhook from `shuttle`, and expects the source to fetch the commit and an event about `scout-staging` to reach the sink.
