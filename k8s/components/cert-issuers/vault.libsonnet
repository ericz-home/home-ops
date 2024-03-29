local ca = std.base64(importstr 'data://get-ca/out/Lab_Root.crt');


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
          path: 'pki/lab/v2024/sign/' + role,
          server: 'https://vault.vault.svc.cluster.local:8200',
          caBundle: ca,
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

issuer('internal-issuer', 'lab-internal-role') + issuer('ingress-issuer', 'lab-ingress-role')
