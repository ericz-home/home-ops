{
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: 'homeassistant',
    labels: {
      'lab.home/gateway': 'homeassistant',
      'lab.home/trust-bundle': 'lab-ca-2029',
    },
  },
}
