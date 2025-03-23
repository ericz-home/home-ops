local route = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: 'splunk',
    namespace: 'splunk',
  },
  spec: {
    parentRefs: [
      {
        name: 'splunk-gateway',
        namespace: 'envoy-gateway',
      },
    ],
    hostnames: ['splunk.lab.home'],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'splunk-splunk-standalone-service',
            port: 8088,
          },
        ],
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/services/collector',
            },
          },
        ],
      },
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'splunk-splunk-standalone-service',
            port: 8000,
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
