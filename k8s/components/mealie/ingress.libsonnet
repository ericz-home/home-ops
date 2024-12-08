local route = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: 'mealie',
    namespace: 'mealie',
  },
  spec: {
    parentRefs: [
      {
        name: 'mealie-gateway',
        namespace: 'envoy-gateway',
      },
    ],
    hostnames: ['mealie.lab.home'],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'mealie',
            port: 3000,
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
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'mealie',
            port: 9000,
          },
        ],
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/api/',
            },
          },
        ],
      },
    ],
  },
};

[route]
