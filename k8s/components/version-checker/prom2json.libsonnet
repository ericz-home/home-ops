{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: 'prom2json',
    namespace: 'version-checker',
  },
  spec: {
    schedule: '0 17 * * *',
    jobTemplate: {
      spec: {
        template: {
          spec: {
            restartPolicy: 'OnFailure',
            containers: [
              {
                name: 'prom2json',
                image: 'prom/prom2json:latest',
                imagePullPolicy: 'Always',
                command: [
                  '/bin/ash',
                ],
                args: [
                  '-c',
                  'wget -O- http://version-checker.version-checker.svc.cluster.local:8080/metrics | grep "version_checker_" | prom2json',
                ],
              },
            ],
          },
        },
      },
    },
  },
}
