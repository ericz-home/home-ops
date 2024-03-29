local vault_annotations =
  {
    'vault.hashicorp.com/tls-secret': 'lab-ca',
    'vault.hashicorp.com/ca-cert': '/vault/tls/ca.crt',
    'vault.hashicorp.com/role': 'homeassistant-secrets-role',
    'vault.hashicorp.com/agent-inject': 'true',
    'vault.hashicorp.com/agent-pre-populate-only': 'true',
    'vault.hashicorp.com/agent-init-first': 'true',
    'vault.hashicorp.com/agent-run-as-user': '1000',
    'vault.hashicorp.com/agent-copy-volume-mounts': 'git-init',
  } +
  // add ssh secrets
  {
    'vault.hashicorp.com/agent-inject-perms-ssh-privatekey': '0600',
    'vault.hashicorp.com/agent-inject-secret-ssh-privatekey': 'secrets/homeassistant/ssh',
    'vault.hashicorp.com/agent-inject-template-ssh-privatekey': |||
      {{ with secret "secrets/homeassistant/ssh" -}}
        {{ .Data.data.privatekey }}
      {{- end }}
    |||,
  } +
  // add mealie secrets
  {
    'vault.hashicorp.com/agent-inject-perms-mealie': '0600',
    'vault.hashicorp.com/agent-inject-secret-mealie': 'secrets/homeassistant/mealie',
    'vault.hashicorp.com/agent-inject-template-mealie': |||
      {{ with secret "secrets/homeassistant/mealie" -}}
        mealie_api_token: Bearer {{ .Data.data.api_token }}
      {{- end }}
    |||,
    'vault.hashicorp.com/agent-inject-command-mealie': |||
      ln -s /vault/secrets/mealie /config/packages/mealie/secrets.yaml
    |||,
  };

local git_sync =
  {
    image: 'alpine/git:user',
    imagePullPolicy: 'IfNotPresent',
    name: 'git-init',
    volumeMounts: [
      {
        name: 'config',
        mountPath: '/config',
      },
    ],
    workingDir: '/config',
    env: [
      {
        name: 'GIT_SSH_COMMAND',
        value: 'ssh -i /vault/secrets/ssh-privatekey -o "StrictHostKeyChecking no"',
      },
    ],
    command: ['/bin/sh', '-c'],
    args: [
      'git pull || git clone git@github.com:ericz-home/homeassistant-config.git .',
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
    namespace: 'homeassistant',
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
        annotations: vault_annotations,
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
                value: 'America/Los_Angeles',
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
            ],
          },
        ],
        serviceAccountName: 'homeassistant',
        restartPolicy: 'Always',
        volumes: [
          {
            name: 'config',
            persistentVolumeClaim: {
              claimName: 'config-pvc',
            },
          },
          {
            name: 'localtime',
            hostPath: {
              path: '/etc/localtime',
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
    name: 'homeassistant',
    namespace: 'homeassistant',
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
