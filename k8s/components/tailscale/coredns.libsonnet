local corefile = importstr './include/Corefile';
local dbfile = importstr './include/db.lab.home';

local configmap = {
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'coredns',
    namespace: 'tailscale',
  },
  data: {
    Corefile: corefile,
    'db.lab.home': dbfile,
  },
};

local deployment = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'coredns',
    namespace: 'tailscale',
    labels: {
      app: 'coredns',
    },
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'coredns',
      },
    },
    replicas: 1,
    template: {
      metadata: {
        labels: {
          app: 'coredns',
        },
      },
      spec: {
        containers: [
          {
            name: 'coredns',
            image: 'coredns/coredns:latest',
            imagePullPolicy: 'Always',
            args: ['-conf', '/etc/coredns/Corefile'],
            volumeMounts: [
              {
                name: 'config',
                mountPath: '/etc/coredns',
              },
            ],
            ports: [
              {
                name: 'dns',
                protocol: 'UDP',
                containerPort: 53,
              },
              {
                name: 'dns-tcp',
                protocol: 'TCP',
                containerPort: 53,
              },
            ],
          },
        ],
        serviceAccountName: 'coredns',
        volumes: [
          {
            name: 'config',
            configMap: {
              name: 'coredns',
            },
          },
        ],
      },
    },
  },
};

local svc = {
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'coredns',
    namespace: 'tailscale',
    labels: {
      'tailscale.com/proxy-class': 'lab',
    },
    annotations: {
      'tailscale.com/expose': 'true',
    },
  },
  spec: {
    selector: {
      app: 'coredns',
    },
    ports: [
      {
        name: 'dns',
        protocol: 'UDP',
        port: 53,
      },
      {
        name: 'dns-tcp',
        protocol: 'TCP',
        port: 53,
      },
    ],
  },
};

[configmap, deployment, svc]
