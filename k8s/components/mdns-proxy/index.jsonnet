local ns = {
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: 'mdns-proxy',
  },
};

local deploy = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    labels: {
      app: 'mdns-proxy',
    },
    name: 'mdns-proxy',
    namespace: 'mdns-proxy',
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'mdns-proxy',
      },
    },
    replicas: 1,
    template: {
      metadata: {
        labels: {
          app: 'mdns-proxy',
        },
      },
      spec: {
        containers: [
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
        restartPolicy: 'Always',
        volumes: [
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

[ns, deploy]
