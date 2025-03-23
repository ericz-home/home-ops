local route = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: 'zigbee2mqtt',
    namespace: 'zigbee2mqtt',
  },
  spec: {
    parentRefs: [
      {
        name: 'zigbee2mqtt-gateway',
        namespace: 'envoy-gateway',
      },
    ],
    hostnames: ['zigbee2mqtt.lab.home'],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'zigbee2mqtt',
            port: 8080,
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
