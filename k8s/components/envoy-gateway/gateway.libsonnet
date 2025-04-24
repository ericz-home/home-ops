local makeGateway(site) = {
  local hostname = site + '.lab.home',
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'Gateway',
  metadata: {
    name: site + '-gateway',
    namespace: 'envoy-gateway',
    annotations: {
      'cert-manager.io/issuer': 'gateway-issuer',
      'cert-manager.io/common-name': hostname,
    },
  },
  spec: {
    gatewayClassName: 'lab-gateway',
    listeners: [
      {
        name: 'https',
        protocol: 'HTTPS',
        port: 4443,
        hostname: hostname,
        allowedRoutes: {
          namespaces: {
            from: 'Selector',
            selector: {
              matchLabels: {
                'lab.home/gateway': site,
              },
            },
          },
          kinds: [{
            group: 'gateway.networking.k8s.io',
            kind: 'HTTPRoute',
          }],
        },
        tls: {
          mode: 'Terminate',
          certificateRefs: [
            {
              name: site + '-gw-tls',
            },
          ],
        },
      },
    ],
  },
};

[makeGateway(site) for site in ['homeassistant', 'vault', 'mealie', 'open-webui', 'zigbee2mqtt', 'splunk']]
