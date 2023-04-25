{
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: 'tailscale',
    labels: {
      'k8s.lab.home/inject-ca': 'true',
    },
  },
}
