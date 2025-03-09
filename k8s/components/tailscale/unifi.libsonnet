{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'unifi',
    namespace: 'tailscale',
    annotations: {
      'tailscale.com/expose': 'true',
    },
  },
  spec: {
    type: 'ExternalName',
    externalName: 'unifi.home',
  },
}
