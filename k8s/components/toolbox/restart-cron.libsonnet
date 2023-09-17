{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: 'restart-deployments',
    namespace: 'toolbox',
  },
  spec: {
    schedule: '0 19 * * *',
    concurrencyPolicy: 'Forbid',
    successfulJobsHistoryLimit: 1,
    jobTemplate: {
      spec: {
        template: {
          spec: {
            containers: [{
              name: 'toolbox',
              image: 'ghcr.io/ericz-home/toolbox:latest',
              imagePullPolicy: 'Always',
              args: ['restart'],
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
