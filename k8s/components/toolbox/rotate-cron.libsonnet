local vault_annotations = {
  'vault.hashicorp.com/tls-secret': 'lab-ca',
  'vault.hashicorp.com/ca-cert': '/vault/tls/ca.crt',
  'vault.hashicorp.com/role': 'toolbox-secrets-role',
  'vault.hashicorp.com/agent-inject': 'true',
  'vault.hashicorp.com/agent-pre-populate-only': 'true',
  'vault.hashicorp.com/agent-init-first': 'true',
  'vault.hashicorp.com/agent-run-as-user': '1000',
  'vault.hashicorp.com/agent-inject-perms-tailscalex': '0600',
  'vault.hashicorp.com/agent-inject-secret-tailscalex': 'secrets/toolbox/tailscalex',
  'vault.hashicorp.com/agent-inject-template-tailscalex': |||
    {{ with secret "secrets/toolbox/tailscalex" -}}
    export TS_API_CLIENT_ID="{{ .Data.data.client_id }}"
    export TS_API_CLIENT_SECRET="{{ .Data.data.client_secret }}"
    {{- end }}
  |||,
};

{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: 'rotate-tailscale',
    namespace: 'toolbox',
  },
  spec: {
    schedule: '0 17 * * *',
    concurrencyPolicy: 'Forbid',
    successfulJobsHistoryLimit: 1,
    jobTemplate: {
      spec: {
        template: {
          metadata: {
            annotations: vault_annotations,
          },
          spec: {
            containers: [{
              name: 'toolbox',
              image: 'ghcr.io/ericz-home/toolbox:latest',
              imagePullPolicy: 'Always',
              args: ['rotate'],
              env: [
                {
                  name: 'TOOLBOX_VAULT_ROLE',
                  value: 'tailscalex-secrets-role',
                },
                {
                  name: 'TS_TOKEN_FILE',
                  value: '/tmp/ts-token',
                },
                {
                  name: 'VAULT_ADDR',
                  value: 'https://vault.vault.svc:8200',
                },
                {
                  name: 'VAULT_CACERT',
                  value: '/vault/tls/ca.crt',
                },
              ],
              volumeMounts: [{
                name: 'lab-ca',
                readOnly: true,
                mountPath: '/vault/tls',
              }],
            }],
            volumes: [{
              name: 'lab-ca',
              secret: {
                secretName: 'lab-ca',
              },
            }],
            serviceAccountName: 'toolbox',
            restartPolicy: 'OnFailure',
            securityContext: {
              runAsUser: 1000,
              runAsGroup: 1000,
              fsGroup: 1000,
            },
          },
        },
        backoffLimit: 3,
      },
    },
  },
}
