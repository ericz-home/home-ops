{
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: 'envoy-gateway',
    labels: {
      'lab.home/trust-bundle': 'lab-ca-2029',
    },
  },
}
