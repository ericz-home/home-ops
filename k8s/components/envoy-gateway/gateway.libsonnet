local gatewayClass = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'GatewayClass',
  metadata: {
    name: 'envoy-gateway',
    namespace: 'envoy-gateway',
  },
  spec: {
    controllerName: 'gateway.envoyproxy.io/gatewayclass-controller',
  },
};

local site(name) = {
  local cert = name + '-ingress-tls',
  local hostname = name + '.lab.home',
  listener: {
    name: 'https',
    protocol: 'HTTPS',
    port: 4443,
    hostname: hostname,
    allowedRoutes: {
      namespaces: {
        from: 'Selector',
        selector: {
          matchLabels: {
            'lab.home/allow-ingress': 'true',
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
          name: cert,
          kind: 'Secret',
          group: '',
        },
      ],
    },
  },
  certificate: {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Certificate',
    metadata: {
      name: cert,
      namespace: 'envoy-gateway',
    },
    spec: {
      secretName: cert,
      commonName: hostname,
      dnsNames: [hostname],
      issuerRef: {
        kind: 'ClusterIssuer',
        name: 'ingress-issuer',
      },
      usages: [
        'digital signature',
        'key encipherment',
      ],
    },
  },
};

local sites = [site(name) for name in ['homeassistant']];

local gateway = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'Gateway',
  metadata: {
    name: 'lab-gateway',
    namespace: 'envoy-gateway',
  },
  spec: {
    gatewayClassName: 'envoy-gateway',
    infrastructure: {
      parametersRef: {
        group: 'gateway.envoyproxy.io',
        kind: 'EnvoyProxy',
        name: 'lab-gw-config',
      },
    },
    listeners: [site.listener for site in sites],
  },
};

// local envoyProxy = {
//   apiVersion: 'gateway.envoyproxy.io/v1alpha1',
//   kind: 'EnvoyProxy',
//   metadata: {
//     name: 'lab-gw-config',
//     namespace: 'envoy-gateway',
//   },
//   spec: {
//     provider: {
//       type: 'Kubernetes',
//       kubernetes: {
//         envoyService: {
//           name: 'lab-ingress',
//         },
//       },
//     },
//   },
// };

[gatewayClass] + [site.certificate for site in sites] + [gateway]
