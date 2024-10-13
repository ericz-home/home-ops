local ca = std.base64(importstr 'data://get-ca/out/Lab_Root.crt');

local gatewayClass = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'GatewayClass',
  metadata: {
    name: 'lab-gateway',
    namespace: 'envoy-gateway',
  },
  spec: {
    controllerName: 'gateway.envoyproxy.io/gatewayclass-controller',
    parametersRef: {
      group: 'gateway.envoyproxy.io',
      kind: 'EnvoyProxy',
      name: 'lab-gw-config',
      namespace: 'envoy-gateway',
    },
  },
};

local envoyProxy = {
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'EnvoyProxy',
  metadata: {
    name: 'lab-gw-config',
    namespace: 'envoy-gateway',
  },
  spec: {
    mergeGateways: true,
    provider: {
      type: 'Kubernetes',
      kubernetes: {
        envoyService: {
          name: 'envoy-lab-gateway',
          annotations: {
            'tailscale.com/expose': 'true',
            'tailscale.com/hostname': 'lab-gateway',
            'tailscale.com/tags': 'tag:lab,tag:k8s',
          },
          patch: {
            type: 'StrategicMerge',
            value: {
              metadata: {
                labels: {
                  'tailscale.com/proxy-class': 'lab',
                },
              },
            },
          },
        },
      },
    },
  },
};

local issuer = [
  {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: 'gateway-issuer',
      namespace: 'envoy-gateway',
    },
  },
  {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'Role',
    metadata: {
      name: 'gateway-issuer',
      namespace: 'envoy-gateway',
    },
    rules: [
      {
        apiGroups: [
          '',
        ],
        resources: [
          'serviceaccounts/token',
        ],
        resourceNames: [
          'gateway-issuer',
        ],
        verbs: [
          'create',
        ],
      },
    ],
  },
  {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'RoleBinding',
    metadata: {
      name: 'gateway-issuer',
      namespace: 'envoy-gateway',
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: 'certmanager-cert-manager',
        namespace: 'certmanager',
      },
    ],
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'Role',
      name: 'gateway-issuer',
    },
  },
  {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Issuer',
    metadata: {
      name: 'gateway-issuer',
      namespace: 'envoy-gateway',
    },
    spec: {
      vault: {
        path: 'pki/lab/v2024/sign/lab-ingress-role',
        server: 'https://vault.vault.svc.cluster.local:8200',
        caBundle: ca,
        auth: {
          kubernetes: {
            role: 'ingress-issuer',
            mountPath: '/v1/auth/kubernetes',
            serviceAccountRef: {
              name: 'gateway-issuer',
            },
          },
        },
      },
    },
  },
];

[gatewayClass, envoyProxy, issuer]
