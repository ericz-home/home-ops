local route = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: 'vault',
    namespace: 'vault',
  },
  spec: {
    parentRefs: [
      {
        name: 'vault-gateway',
        namespace: 'envoy-gateway',
      },
    ],
    hostnames: ['vault.lab.home'],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'vault',
            port: 8200,
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

local policy = {
  apiVersion: 'gateway.networking.k8s.io/v1alpha3',
  kind: 'BackendTLSPolicy',
  metadata: {
    name: 'vault-backend-tls',
    namespace: 'vault',
  },
  spec: {
    targetRefs: [
      {
        group: '',
        kind: 'Service',
        name: 'vault',
        sectionName: '8200',
      },
    ],
    validation: {
      caCertificateRefs: [
        {
          name: 'vault-tls',
          group: '',
          kind: 'Secret',
        },
      ],
      hostname: 'vault.vault.svc.cluster.local',
    },
  },
};

[policy, route]
