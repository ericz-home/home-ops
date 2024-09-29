local gatewaycert = {
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'envoy-gateway',
    namespace: 'envoy-gateway',
  },
  spec: {
    secretName: 'envoy-gateway',
    commonName: 'envoy-gateway',
    dnsNames: [
      'envoy-gateway',
      'envoy-gateway.envoy-gateway',
      'envoy-gateway.envoy-gateway.svc',
      'envoy-gateway.envoy-gateway.svc.cluster.local',
    ],
    issuerRef: {
      kind: 'ClusterIssuer',
      name: 'internal-issuer',
    },
    usages: [
      'digital signature',
      'data encipherment',
      'key encipherment',
      'content commitment',
    ],
  },
};

local envoycert = {
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'envoy',
    namespace: 'envoy-gateway',
  },
  spec: {
    secretName: 'envoy',
    commonName: '*',
    dnsNames: [
      '*.envoy-gateway',
    ],
    issuerRef: {
      kind: 'ClusterIssuer',
      name: 'internal-issuer',
    },
    usages: [
      'digital signature',
      'data encipherment',
      'key encipherment',
      'content commitment',
    ],
  },
};

local ratelimitcert = {
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'envoy-rate-limit',
    namespace: 'envoy-gateway',
  },
  spec: {
    secretName: 'envoy-rate-limit',
    commonName: '*',
    dnsNames: [
      '*.envoy-gateway',
    ],
    issuerRef: {
      kind: 'ClusterIssuer',
      name: 'internal-issuer',
    },
    usages: [
      'digital signature',
      'data encipherment',
      'key encipherment',
      'content commitment',
    ],
  },
};

[gatewaycert, envoycert, ratelimitcert]
