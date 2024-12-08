local issuer = function(name, role)
  [
    {
      apiVersion: 'v1',
      kind: 'ServiceAccount',
      metadata: {
        name: name,
        namespace: 'cert-issuers',
      },
    },
    {
      apiVersion: 'v1',
      kind: 'Secret',
      metadata: {
        name: name + '-token',
        namespace: 'cert-issuers',
        annotations: {
          'kubernetes.io/service-account.name': name,
        },
      },
      type: 'kubernetes.io/service-account-token',
      data: {},
    },
    {
      apiVersion: 'cert-manager.io/v1',
      kind: 'ClusterIssuer',
      metadata: {
        name: name,
        namespace: 'cert-issuers',
      },
      spec: {
        vault: {
          path: 'pki/lab/v2025/sign/' + role,
          server: 'https://vault.vault.svc.cluster.local:8200',
          caBundleSecretRef: {
            name: 'lab-ca',
            key: 'ca.crt',
          },
          auth: {
            kubernetes: {
              role: name,
              mountPath: '/v1/auth/kubernetes',
              secretRef: {
                name: name + '-token',
                key: 'token',
              },
            },
          },
        },
      },
    },
  ];

issuer('internal-issuer', 'lab-internal-role')
