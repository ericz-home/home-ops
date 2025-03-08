local route = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: 'open-webui',
    namespace: 'open-webui',
  },
  spec: {
    parentRefs: [
      {
        name: 'open-webui-gateway',
        namespace: 'envoy-gateway',
      },
    ],
    hostnames: ['ai.lab.home', 'open-webui.lab.home'],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'open-webui',
            port: 80,
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
