local corefile = importstr './include/Corefile';
local dbfile = importstr './include/db.lab.home';

local configmap = {
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'coredns',
    namespace: 'tailscale',
  },
  data: {
    Corefile: corefile,
    'db.lab.home': dbfile,
  },
};

local vault_annotations =
  {
    'vault.hashicorp.com/tls-secret': 'lab-ca',
    'vault.hashicorp.com/ca-cert': '/vault/tls/ca.crt',
    'vault.hashicorp.com/role': 'tailscale-secrets-role',
    'vault.hashicorp.com/agent-inject': 'true',
    'vault.hashicorp.com/agent-pre-populate-only': 'true',
    'vault.hashicorp.com/agent-run-as-user': '1000',
  } +
  // add tailscale authkey
  {
    'vault.hashicorp.com/agent-inject-secret-tailscale': 'secrets/tailscale/coredns',
    'vault.hashicorp.com/agent-inject-template-tailscale': |||
      {{ with secret "secrets/tailscale/coredns" -}}
        export TS_AUTHKEY="{{ .Data.data.authkey }}"
      {{- end }}
    |||,
  };

local deployment = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'coredns',
    namespace: 'tailscale',
    labels: {
      app: 'coredns',
    },
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'coredns',
      },
    },
    replicas: 1,
    template: {
      metadata: {
        labels: {
          app: 'coredns',
        },
        annotations: vault_annotations,
      },
      spec: {
        containers: [
          {
            name: 'coredns',
            image: 'coredns/coredns:latest',
            imagePullPolicy: 'Always',
            args: ['-conf', '/etc/coredns/Corefile'],
            volumeMounts: [
              {
                name: 'config',
                mountPath: '/etc/coredns',
              },
            ],
            ports: [
              {
                name: 'dns',
                protocol: 'UDP',
                containerPort: 53,
              },
              {
                name: 'dns-tcp',
                protocol: 'TCP',
                containerPort: 53,
              },
            ],
          },
          {
            name: 'tailscale',
            imagePullPolicy: 'Always',
            image: 'ghcr.io/tailscale/tailscale:latest',
            securityContext: {
              capabilities: {
                add: ['NET_ADMIN'],
              },
            },
            command: ['/bin/sh', '-c'],
            args: ['source /vault/secrets/tailscale && /usr/local/bin/containerboot'],
            env: [
              {
                name: 'TS_KUBE_SECRET',
                value: 'coredns-auth',
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
                value: 'dns-tailscale',
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
        serviceAccountName: 'tailscale',
        volumes: [
          {
            name: 'config',
            configMap: {
              name: 'coredns',
            },
          },
          {
            name: 'tun',
            hostPath: {
              path: '/dev/net/tun',
            },
          },
        ],
      },
    },
  },
};

[configmap, deployment]
