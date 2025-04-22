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
      ln -sf /vault/secrets/mealie /config/packages/mealie/secrets.yaml
    |||,
  } +
  // add onebusaway secrets
  {
    'vault.hashicorp.com/agent-inject-perms-gtfs': '0600',
    'vault.hashicorp.com/agent-inject-secret-gtfs': 'secrets/homeassistant/gtfs',
    'vault.hashicorp.com/agent-inject-template-gtfs': |||
      {{ with secret "secrets/homeassistant/gtfs" -}}
      bus_trip_update_url: "http://api.pugetsound.onebusaway.org/api/gtfs_realtime/trip-updates-for-agency/1.pb?key={{ .Data.data.api_key }}"
      bus_vehicle_position_url: "http://api.pugetsound.onebusaway.org/api/gtfs_realtime/vehicle-positions-for-agency/1.pb?key={{ .Data.data.api_key }}"
      rail_trip_update_url: "http://api.pugetsound.onebusaway.org/api/gtfs_realtime/trip-updates-for-agency/40.pb?key={{ .Data.data.api_key }}"
      rail_vehicle_position_url: "http://api.pugetsound.onebusaway.org/api/gtfs_realtime/vehicle-positions-for-agency/40.pb?key={{ .Data.data.api_key }}"
      {{- end }}
    |||,
    'vault.hashicorp.com/agent-inject-command-gtfs': |||
      ln -sf /vault/secrets/gtfs /config/packages/gtfs_rt/secrets.yaml
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
      '(git submodule update --init --recursive; git pull --recurse-submodules) || git clone git@github.com:ericz-home/homeassistant-config.git .',
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
                value: '/tmp/matplotlib',
              },
              {
                name: 'XDG_CONFIG_HOME',
                value: '/config/container-venv/xdg/config',
              },
              {
                name: 'XDG_CACHE_HOME',
                value: '/config/container-venv/xdg/cache',
              },
              {
                name: 'UV_NO_CACHE',
                value: 'false',
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
                name: 'config',
                mountPath: '/etc/services.d/home-assistant/run',
                subPath: 'container-venv/run',
              },
              {
                name: 'lab-ca',
                mountPath: '/vault/tls/ca.crt',
                subPath: 'ca.crt',
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
            name: 'lab-ca',
            secret: {
              secretName: 'lab-ca',
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
