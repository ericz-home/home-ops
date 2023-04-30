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
    'vault.hashicorp.com/agent-inject-secret-tailscale': 'secrets/tailscale/lab-gw',
    'vault.hashicorp.com/agent-inject-template-tailscale': |||
      {{ with secret "secrets/tailscale/lab-gw" -}}
        export TS_AUTHKEY="{{ .Data.data.authkey }}"
      {{- end }}
    |||,
  };


{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    labels: {
      app: 'lab-gw',
    },
    annotations: {
      description: 'tailscale gateway for lab.home',
    },
    name: 'lab-gw',
    namespace: 'tailscale',
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'lab-gw',
      },
    },
    replicas: 1,
    template: {
      metadata: {
        labels: {
          app: 'lab-gw',
        },
        annotations: vault_annotations,
      },
      spec: {
        initContainers: [
          {
            name: 'sysctler',
            image: 'busybox',
            securityContext: {
              privileged: true,
            },
            command: ['/bin/sh'],
            args: ['-c', 'sysctl -w net.ipv4.ip_forward=1 net.ipv6.conf.all.forwarding=1'],
          },
        ],
        serviceAccountName: 'tailscale',
        containers: [
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
                value: 'tailscale-auth',
              },
              {
                name: 'TS_USERSPACE',
                value: 'false',
              },
              {
                name: 'TS_DEST_IP',
                value: '10.43.38.159',  // kubectl -n projectcontour get svc envoy
              },
              {
                name: 'TS_AUTH_ONCE',
                value: 'true',
              },
              {
                name: 'TS_HOSTNAME',
                value: 'lab-gw',
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
        volumes: [
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
}
