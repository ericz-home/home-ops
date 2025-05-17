local deploy = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    labels: {
      app: 'mqtt',
    },
    name: 'mqtt',
    namespace: 'mqtt',
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'mqtt',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'mqtt',
        },
      },
      spec: {
        containers: [
          {
            image: 'eclipse-mosquitto:latest',
            imagePullPolicy: 'Always',
            name: 'mqtt',
            ports: [
              {
                name: 'mqtt',
                containerPort: 8883,
                protocol: 'TCP',
              },
            ],
            volumeMounts: [
              {
                name: 'config',
                mountPath: '/mosquitto/config/mosquitto.conf',
                subPath: 'mosquitto.conf',
                readOnly: true,
              },
              {
                name: 'config',
                mountPath: '/mosquitto/config/aclfile',
                subPath: 'aclfile',
                readOnly: true,
              },
              {
                name: 'mqtt-tls',
                mountPath: '/mosquitto/config/certs',
                readOnly: true,
              },
              {
                name: 'mqtt-data',
                mountPath: '/mosquitto/data',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: {
              name: 'mqtt',
              defaultMode: 448,  // 0700
            },
          },
          {
            name: 'mqtt-tls',
            secret: {
              defaultMode: 420,  // 0644
              secretName: 'mqtt-tls',
            },
          },
          {
            name: 'mqtt-data',
            persistentVolumeClaim: {
              claimName: 'mqtt-pvc',
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
  },
};

local svc = {
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'mqtt',
    namespace: 'mqtt',
  },
  spec: {
    selector: {
      app: 'mqtt',
    },
    ports: [
      {
        protocol: 'TCP',
        port: 8883,
        name: 'mqtt',
      },
    ],
  },
};

[deploy, svc]
