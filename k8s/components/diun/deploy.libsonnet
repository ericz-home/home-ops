local vault_annotations =
  {
    'vault.hashicorp.com/tls-secret': 'lab-ca',
    'vault.hashicorp.com/ca-cert': '/vault/tls/ca.crt',
    'vault.hashicorp.com/role': 'diun-secrets-role',
    'vault.hashicorp.com/agent-inject': 'true',
    'vault.hashicorp.com/agent-pre-populate-only': 'true',
    'vault.hashicorp.com/agent-init-first': 'true',
    'vault.hashicorp.com/agent-run-as-user': '1000',
  } +
  {
    'vault.hashicorp.com/agent-inject-perms-discord': '0600',
    'vault.hashicorp.com/agent-inject-secret-discord': 'secrets/diun/discord',
    'vault.hashicorp.com/agent-inject-template-discord': |||
      {{ with secret "secrets/diun/discord" -}}
      {{ .Data.data.webhookURL }}
      {{- end }}
    |||,
  };


{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    namespace: 'diun',
    name: 'diun',
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        app: 'diun',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'diun',
        },
        annotations: vault_annotations,
      },
      spec: {
        serviceAccountName: 'diun',
        containers: [
          {
            name: 'diun',
            image: 'crazymax/diun:latest',
            imagePullPolicy: 'Always',
            args: [
              'serve',
            ],
            env: [
              {
                name: 'TZ',
                value: 'America/Los_Angeles',
              },
              {
                name: 'LOG_LEVEL',
                value: 'info',
              },
              {
                name: 'LOG_JSON',
                value: 'true',
              },
              {
                name: 'CONFIG',
                value: '/config/diun.yaml',
              },
            ],
            volumeMounts: [
              {
                mountPath: '/data',
                name: 'data',
              },
              {
                mountPath: '/config',
                name: 'config',
              },
            ],
          },
        ],
        restartPolicy: 'Always',
        volumes: [
          {
            name: 'data',
            persistentVolumeClaim: {
              claimName: 'diun-pvc',
            },
          },
          {
            name: 'config',
            configMap: {
              name: 'diun',
            },
          },
        ],
      },
    },
  },
}
