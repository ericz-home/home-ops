{
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'vault-data',
    labels: {
      app: 'vault',
    },
  },
  spec: {
    capacity: {
      storage: '5Gi',
    },
    volumeMode: 'Filesystem',
    accessModes: [
      'ReadWriteOnce',
    ],
    persistentVolumeReclaimPolicy: 'Retain',
    storageClassName: 'local-storage',
    'local': {
      path: '/var/lib/rancher/k3s/storage/vault/data',
    },
    nodeAffinity: {
      required: {
        nodeSelectorTerms: [
          {
            matchExpressions: [
              {
                key: 'k8s.lab.home/workload',
                operator: 'In',
                values: ['infra'],
              },
            ],
          },
        ],
      },
    },
  },
}
