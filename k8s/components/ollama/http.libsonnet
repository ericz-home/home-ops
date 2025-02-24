local route = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: 'ollama',
    namespace: 'ollama',
  },
  spec: {
    parentRefs: [
      {
        name: 'ollama-gateway',
        namespace: 'envoy-gateway',
      },
    ],
    hostnames: ['ollama.lab.home'],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'ollama',
            port: 11434,
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
