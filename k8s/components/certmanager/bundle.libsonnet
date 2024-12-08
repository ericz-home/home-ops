local ca = importstr 'data://get-ca/root/2029/Lab_Root_2029.crt';
local caOld = importstr 'data://get-ca/root/2024/Lab_Root.crt';

{
  apiVersion: 'trust.cert-manager.io/v1alpha1',
  kind: 'Bundle',
  metadata: {
    name: 'lab-ca',
    namespace: 'certmanager',
  },
  spec: {
    sources: [
      {
        inLine: ca + caOld,
      },
    ],
    target: {
      secret: {
        key: 'ca.crt',
      },
      namespaceSelector: {
        matchLabels: {
          'lab.home/trust-bundle': 'lab-ca-2029',
        },
      },
    },
  },
}
