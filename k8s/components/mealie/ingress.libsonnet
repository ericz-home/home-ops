local ingress = {
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: 'mealie',
    namespace: 'mealie',
    annotations: {
      'cert-manager.io/cluster-issuer': 'ingress-issuer',
      'cert-manager.io/common-name': 'mealie.lab.home',
    },
  },
  spec: {
    tls: [
      {
        hosts: ['mealie.lab.home'],
        secretName: 'mealie-tls',
      },
    ],
    rules: [
      {
        host: 'mealie.lab.home',
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'mealie',
                  port: {
                    number: 3000,
                  },
                },
              },
            },
            {
              path: '/api/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'mealie',
                  port: {
                    number: 9000,
                  },
                },
              },
            },
          ],
        },
      },
    ],
  },
};

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

[ingress, route]
