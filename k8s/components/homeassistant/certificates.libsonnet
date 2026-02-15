[
  {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Certificate',
    metadata: {
      name: 'mqtt-auth',
      namespace: 'homeassistant',
    },
    spec: {
      secretName: 'mqtt-auth',
      duration: '4320h',  //180d
      renewBefore: '360h',  //15d
      isCA: false,
      commonName: 'homeassistant',
      privateKey: {
        algorithm: 'RSA',
        encoding: 'PKCS1',
        size: 2048,
      },
      dnsNames: ['homeassistant'],
      issuerRef: {
        kind: 'ClusterIssuer',
        name: 'internal-issuer',
      },
    },
  },
]
