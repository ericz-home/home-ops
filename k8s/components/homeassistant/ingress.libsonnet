local ingress = {
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: 'homeassistant',
    namespace: 'homeassistant',
  },
  spec: {
    tls: [
      {
        hosts: ['homeassistant.lab.home'],
        secretName: 'homeassistant-tls',
      },
    ],
    rules: [
      {
        host: 'homeassistant.lab.home',
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'homeassistant',
                  port: {
                    number: 8123,
                  },
                },
              },
            },
          ],
        },
      },
    ],
  },
};

[ingress]
