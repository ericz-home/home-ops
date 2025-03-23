[
  {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Certificate',
    metadata: {
      name: 'mqtt-auth',
      namespace: 'zigbee2mqtt',
    },
    spec: {
      secretName: 'mqtt-auth',
      duration: '2160h',  //90d
      renewBefore: '360h',  //15d
      isCA: false,
      commonName: 'zigbee2mqtt',
      privateKey: {
        algorithm: 'RSA',
        encoding: 'PKCS1',
        size: 2048,
      },
      dnsNames: ['zigbee2mqtt'],
      issuerRef: {
        kind: 'ClusterIssuer',
        name: 'internal-issuer',
      },
    },
  },
]
