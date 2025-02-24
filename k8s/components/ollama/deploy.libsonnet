local deploy = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    labels: {
      app: 'ollama',
    },
    name: 'ollama',
    namespace: 'ollama',
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'ollama',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'ollama',
        },
      },
      spec: {
        runtimeClassName: 'nvidia',
        containers: [
          {
            name: 'ollama',
            image: 'ollama/ollama',
            imagePullPolicy: 'Always',
            ports: [
              {
                name: 'http',
                containerPort: 11434,
                protocol: 'TCP',
              },
            ],
            volumeMounts: [
              {
                mountPath: '/data/models',
                subPath: 'models',
                name: 'ollama-storage',
              },
              {
                mountPath: '/.ollama',
                subPath: 'server',
                name: 'ollama-storage',
              },
            ],
            env: [
              { name: 'PRELOAD_MODELS', value: 'mistral llama3.1 deepseek-r1' },
              { name: 'OLLAMA_KEEP_ALIVE', value: '1h' },
              { name: 'OLLAMA_MODELS', value: '/data/models' },
              { name: 'OLLAMA_MAX_LOADED_MODELS', value: '3' },
            ],
            lifecycle: {
              postStart: {
                exec: {
                  command: ['/bin/sh', '-c', 'for model in $PRELOAD_MODELS; do ollama run $model ""; done'],
                },
              },
            },
            securityContext: {
              allowPrivilegeEscalation: true,
            },
          },
        ],
        volumes: [
          {
            name: 'ollama-storage',
            persistentVolumeClaim: {
              claimName: 'ollama-pvc',
            },
          },
        ],
        securityContext: {
          // TODO: nvidia runtime can't run container as user because a chown /dev/stdout fails during user setup
          // runAsUser: 1000,
          // runAsGroup: 1000,
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
    name: 'ollama',
    namespace: 'ollama',
  },
  spec: {
    selector: {
      app: 'ollama',
    },
    ports: [
      {
        protocol: 'TCP',
        port: 11434,
        name: 'http',
      },
    ],
  },
};

[deploy, svc]
