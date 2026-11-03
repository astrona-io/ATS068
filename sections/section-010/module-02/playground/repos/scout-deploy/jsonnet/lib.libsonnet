{
  deployment(name, replicas, message):: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: { name: name },
    spec: {
      replicas: replicas,
      progressDeadlineSeconds: 60,
      selector: { matchLabels: { app: name } },
      template: {
        metadata: { labels: { app: name } },
        spec: {
          containers: [{
            name: name,
            image: 'ghcr.io/stefanprodan/podinfo:6.15.0',
            env: [{ name: 'PODINFO_UI_MESSAGE', value: message }],
            ports: [{ name: 'http', containerPort: 9898 }],
            readinessProbe: { httpGet: { path: '/readyz', port: 'http' } },
            resources: { requests: { cpu: '10m', memory: '32Mi' } },
          }],
        },
      },
    },
  },
  service(name):: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: { name: name },
    spec: {
      selector: { app: name },
      ports: [{ name: 'http', port: 80, targetPort: 'http' }],
    },
  },
}
