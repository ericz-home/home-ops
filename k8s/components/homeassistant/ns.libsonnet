{
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: 'homeassistant',
    labels: {
      'lab.home/allow-ingress': 'true',
    },
  },
}
