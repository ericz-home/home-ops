local vault_annotations =
  {
    'vault.hashicorp.com/tls-secret': 'envoycert',
    'vault.hashicorp.com/ca-cert': '/vault/tls/ca.crt',
    'vault.hashicorp.com/role': 'projectcontour-secrets-role',
    'vault.hashicorp.com/agent-inject': 'true',
    'vault.hashicorp.com/agent-pre-populate-only': 'true',
    'vault.hashicorp.com/agent-run-as-user': '1000',
    'vault.hashicorp.com/template-config-exit-on-retry-failure': 'false',
  } +
  // add tailscale authkey
  {
    'vault.hashicorp.com/agent-inject-secret-tailscale': 'secrets/projectcontour/tailscale',
    'vault.hashicorp.com/agent-inject-template-tailscale': |||
      {{ with secret "secrets/projectcontour/tailscale" -}}
        export TS_AUTHKEY="{{ .Data.data.authkey }}"
      {{- end }}
    |||,
  };

local proxy = {
  metadata+: {
    annotations+: vault_annotations,
  },
  spec+: {
    automountServiceAccountToken: true,
    containers+: [
      {
        name: 'tailscale',
        imagePullPolicy: 'Always',
        image: 'ghcr.io/tailscale/tailscale:latest',
        securityContext: {
          runAsNonRoot: false,
          runAsUser: 0,
          capabilities: {
            add: ['NET_ADMIN'],
          },
        },
        command: ['/bin/sh', '-c'],
        args: ['source /vault/secrets/tailscale && /usr/local/bin/containerboot'],
        env: [
          {
            name: 'TS_KUBE_SECRET',
            value: 'tailscale-auth',
          },
          {
            name: 'TS_USERSPACE',
            value: 'false',
          },
          {
            name: 'TS_AUTH_ONCE',
            value: 'true',
          },
          {
            name: 'TS_HOSTNAME',
            value: 'contour-envoy',
          },
        ],
        volumeMounts: [
          {
            name: 'tun',
            mountPath: '/dev/net/tun',
          },
        ],
      },
    ],
    volumes+: [
      {
        name: 'tun',
        hostPath: {
          path: '/dev/net/tun',
        },
      },
    ],
  },
};

local role = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: 'tailscale',
    namespace: 'projectcontour',
  },
  rules: [
    {
      apiGroups: [''],  // indicates the core API group
      resources: ['secrets'],
      verbs: ['create'],  // create cannot be restricted to a resource name
    },
    {
      apiGroups: [''],  // indicates the core API group
      resources: ['secrets'],
      resourceNames: ['tailscale-auth'],
      verbs: ['get', 'update', 'patch'],  // create cannot be restricted to a resource name
    },
  ],
};

local binding = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: 'tailscale',
    namespace: 'projectcontour',
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: 'envoy',
    },
  ],
  roleRef: {
    kind: 'Role',
    name: 'tailscale',
    apiGroup: 'rbac.authorization.k8s.io',
  },
};

{
  proxy:: proxy,
  rbac:: [role, binding],
}
