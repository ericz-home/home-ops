[
  {
    apiVersion: 'cert-manager.io/v1',
    kind: 'Certificate',
    metadata: {
      name: 'mqtt-tls',
      namespace: 'mqtt',
    },
    spec: {
      secretName: 'mqtt-tls',
      duration: '2160h',  //90d
      renewBefore: '360h',  //15d
      isCA: false,
      commonName: 'mqtt',
      privateKey: {
        algorithm: 'RSA',
        encoding: 'PKCS1',
        size: 2048,
      },
      dnsNames: ['mqtt', 'mqtt.mqtt', 'mqtt.mqtt.svc', 'mqtt.mqtt.svc.cluster.local'],
      ipAddresses: ['127.0.0.1'],
      issuerRef: {
        kind: 'ClusterIssuer',
        name: 'internal-issuer',
      },
    },
  },
]
