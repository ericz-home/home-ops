local git_sync =
  {
    image: 'registry.k8s.io/git-sync/git-sync:v3.6.2',
    imagePullPolicy: 'IfNotPresent',
    name: 'git-sync',
    volumeMounts: [
      {
        name: 'ssh',
        mountPath: '/.ssh/',
        readOnly: true,
      },
      {
        name: 'config',
        mountPath: '/config',
      },
      {
        name: 'git',
        mountPath: '/git',
      },
    ],
    args: [
      '--add-user',
      '--dest',
      'current',
      '--wait',
      '10',
      '--repo',
      'git@github.com:e-zhang/homeassistant-config.git',
      '--branch',
      'main',
      '--root',
      '/git',
      '--ssh',
      '--ssh-key-file',
      '/.ssh/ssh-privatekey',
      '--ssh-known-hosts-file',
      '/.ssh/known_hosts',
      '--one-time',
    ],
  };

local deploy = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    labels: {
      app: 'homeassistant',
    },
    name: 'homeassistant',
  },

  spec: {
    selector: {
      matchLabels: {
        app: 'homeassistant',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'homeassistant',
        },
      },
      spec: {
        initContainers: [
          git_sync,
        ],
        containers: [
          {
            image: 'ghcr.io/home-assistant/home-assistant:stable',
            imagePullPolicy: 'Always',
            name: 'homeassistant',
            env: [
              {
                name: 'TZ',
                value: 'TZ=America/Los_Angeles',
              },
              {
                name: 'MPLCONFIGDIR',
                value: '/config/matplotlib',
              },
            ],
            ports: [
              {
                containerPort: 8123,
                protocol: 'TCP',
              },
            ],
            volumeMounts: [
              {
                name: 'localtime',
                mountPath: '/etc/localtime',
                readOnly: true,
              },
              {
                name: 'config',
                mountPath: '/config',
              },
              {
                name: 'git',
                mountPath: '/git',
              },
            ],
          },
        ],
        restartPolicy: 'Always',
        volumes: [
          {
            name: 'config',
            persistentVolumeClaim: {
              claimName: 'config',
            },
          },
          {
            name: 'localtime',
            hostPath: {
              path: '/etc/localtime',
            },
          },
          {
            name: 'ssh',
            secret: {
              secretName: 'ssh-key-git',
            },
          },
          {
            name: 'git',
            emptyDir: {},
          },
        ],
        securityContext: {
          runAsUser: 1000,
          runAsGroup: 1000,
        },
      },
    },
  },
};

local svc = {
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'homeassistant',
  },
  spec: {
    selector: {
      app: 'homeassistant',
    },
    ports: [
      {
        protocol: 'TCP',
        port: 8123,
        name: 'http',
      },
    ],
  },
};

[
  deploy,
  svc,
]
