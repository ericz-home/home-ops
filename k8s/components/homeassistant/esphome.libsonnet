local deploy = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    labels: {
      app: 'esphome',
    },
    name: 'esphome',
    namespace: 'homeassistant',
  },

  spec: {
    selector: {
      matchLabels: {
        app: 'esphome',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'esphome',
        },
      },
      spec: {
        containers: [
          {
            image: 'ghcr.io/esphome/esphome:stable',
            imagePullPolicy: 'Always',
            name: 'esphome',
            ports: [
              {
                containerPort: 6052,
                protocol: 'TCP',
              },
            ],
            volumeMounts: [
              {
                name: 'config',
                mountPath: '/config',
              },
            ],
          },
        ],
        restartPolicy: 'Always',
        volumes: [
          {
            name: 'config',
            persistentVolumeClaim: {
              claimName: 'esphome-pvc',
            },
          },
        ],
      },
    },
  },
};

[deploy]
