local vault_annotations =
  {
    'vault.hashicorp.com/tls-secret': 'lab-ca',
    'vault.hashicorp.com/ca-cert': '/vault/tls/ca.crt',
    'vault.hashicorp.com/role': 'homeassistant-secrets-role',
    'vault.hashicorp.com/agent-inject': 'true',
    'vault.hashicorp.com/agent-pre-populate-only': 'true',
    'vault.hashicorp.com/agent-init-first': 'true',
    'vault.hashicorp.com/agent-run-as-user': '1000',
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
  // add unifi secrets
  {
    'vault.hashicorp.com/agent-inject-perms-unifi': '0600',
    'vault.hashicorp.com/agent-inject-secret-unifi': 'secrets/homeassistant/unifi-ssh',
    'vault.hashicorp.com/agent-inject-template-unifi': |||
      {{ with secret "secrets/homeassistant/unifi-ssh" -}}
      unifi_username: {{ .Data.data.username }}
      unifi_password: {{ .Data.data.password }}
      unifi_ip: {{ .Data.data.ip }}
      {{- end }}
    |||,
    'vault.hashicorp.com/agent-inject-command-unifi': |||
      ln -sf /vault/secrets/unifi /config/device_trackers/unifi/secrets.yaml
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
                name: 'backups',
                mountPath: '/config/backups',
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
          {
            image: 'ghcr.io/ericz-home/mdns-proxy:2025-02-15',
            imagePullPolicy: 'Always',
            name: 'mdns-proxy',
            volumeMounts: [
              {
                name: 'avahi',
                mountPath: '/var/run/avahi-daemon/socket',
              },
              {
                name: 'dbus',
                mountPath: '/var/run/dbus/system_bus_socket',
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
            name: 'backups',
            persistentVolumeClaim: {
              claimName: 'backup-pvc',
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
          {
            name: 'avahi',
            hostPath: {
              path: '/home/home/Documents/work/k3s/mdns/avahi.sock',
              type: 'Socket',
            },
          },
          {
            name: 'dbus',
            hostPath: {
              path: '/home/home/Documents/work/k3s/mdns/dbus.sock',
              type: 'Socket',
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
