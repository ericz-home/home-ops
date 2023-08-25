local vault_annotations = {
  'vault.hashicorp.com/tls-secret': 'lab-ca',
  'vault.hashicorp.com/ca-cert': '/vault/tls/ca.crt',
  'vault.hashicorp.com/role': 'feeds-to-pocket-secrets-role',
  'vault.hashicorp.com/agent-inject': 'true',
  'vault.hashicorp.com/agent-pre-populate-only': 'true',
  'vault.hashicorp.com/agent-init-first': 'true',
  'vault.hashicorp.com/agent-run-as-user': '1000',
  'vault.hashicorp.com/agent-inject-perms-pocket': '0600',
  'vault.hashicorp.com/agent-inject-secret-pocket': 'secrets/feeds-to-pocket/pocket',
  'vault.hashicorp.com/agent-inject-template-pocket': |||
    {{ with secret "secrets/feeds-to-pocket/pocket" -}}
    consumer_key: {{ .Data.data.consumer_key }}
    access_token: {{ .Data.data.access_token }}
    {{- end }}
  |||,
};

{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: 'feeds-to-pocket',
    namespace: 'feeds-to-pocket',
  },
  spec: {
    schedule: '0 */4 * * *',
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
              name: 'feeds-to-pocket',
              image: 'ghcr.io/ericz-home/feeds-to-pocket:0.1.7',
              imagePullPolicy: 'Always',
              args: [
                '/feeds/feeds-to-pocket.yaml',
                '/vault/secrets/pocket',
              ],
              volumeMounts: [
                {
                  name: 'feeds',
                  mountPath: '/feeds',
                },
              ],
            }],
            serviceAccountName: 'feeds-to-pocket',
            restartPolicy: 'OnFailure',
            volumes: [
              {
                name: 'feeds',
                persistentVolumeClaim: {
                  claimName: 'feeds-pvc',
                },
              },
            ],
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
