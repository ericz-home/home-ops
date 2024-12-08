local route = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: 'homeassistant',
    namespace: 'homeassistant',
  },
  spec: {
    parentRefs: [
      {
        name: 'homeassistant-gateway',
        namespace: 'envoy-gateway',
      },
    ],
    hostnames: ['homeassistant.lab.home'],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'homeassistant',
            port: 8123,
          },
        ],
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/',
            },
          },
        ],
      },
    ],
  },
};

[route]
