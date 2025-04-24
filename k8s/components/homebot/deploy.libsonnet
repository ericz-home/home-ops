local vault_annotations = {
  'vault.hashicorp.com/tls-secret': 'lab-ca',
  'vault.hashicorp.com/ca-cert': '/vault/tls/ca.crt',
  'vault.hashicorp.com/role': 'homebot-secrets-role',
  'vault.hashicorp.com/agent-inject': 'true',
  'vault.hashicorp.com/agent-pre-populate-only': 'true',
  'vault.hashicorp.com/agent-init-first': 'true',
  'vault.hashicorp.com/agent-run-as-user': '1000',
  'vault.hashicorp.com/agent-inject-perms-discord': '0600',
  'vault.hashicorp.com/agent-inject-secret-discord': 'secrets/homebot/discord',
  'vault.hashicorp.com/agent-inject-template-discord': |||
    {{ with secret "secrets/homebot/discord" -}}
    {{ .Data.data.token }}
    {{- end }}
  |||,
  'vault.hashicorp.com/agent-inject-perms-homeassistant': '0600',
  'vault.hashicorp.com/agent-inject-secret-homeassistant': 'secrets/homebot/homeassistant',
  'vault.hashicorp.com/agent-inject-template-homeassistant': |||
    {{ with secret "secrets/homebot/homeassistant" -}}
    {{ .Data.data.token }}
    {{- end }}
  |||,
};

local deploy = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    labels: {
      app: 'homebot',
    },
    name: 'homebot',
    namespace: 'homebot',
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'homebot',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'homebot',
        },
        annotations: vault_annotations,
      },
      spec: {
        containers: [
          {
            image: 'ghcr.io/ericz-home/homebot:2025-04-24',
            imagePullPolicy: 'Always',
            name: 'homebot',
            env: [
              {
                name: 'DISCORD_TOKEN_PATH',
                value: '/vault/secrets/discord',
              },
              {
                name: 'HOME_ASSISTANT_TOKEN_PATH',
                value: '/vault/secrets/homeassistant',
              },
              {
                name: 'HOME_ASSISTANT_URL',
                value: 'http://homeassistant.homeassistant.svc.cluster.local:8123',
              },
            ],
          },
        ],
        serviceAccountName: 'homebot',
        restartPolicy: 'Always',
        securityContext: {
          runAsUser: 1000,
          runAsGroup: 1000,
          fsGroup: 1000,
        },
      },
    },
  },
};

[deploy]
