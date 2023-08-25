local pv = {
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'feeds-to-pocket-config',
    labels: {
      app: 'feeds-to-pocket',
    },
  },
  spec: {
    capacity: {
      storage: '1Gi',
    },
    volumeMode: 'Filesystem',
    accessModes: [
      'ReadWriteOnce',
    ],
    persistentVolumeReclaimPolicy: 'Retain',
    storageClassName: 'local-storage',
    'local': {
      path: '/home/home/Documents/work/k3s/storage/feeds-to-pocket/',
    },
    claimRef: {
      name: 'feeds-pvc',
      namespace: 'feeds-to-pocket',
    },
    nodeAffinity: {
      required: {
        nodeSelectorTerms: [
          {
            matchExpressions:
              [{
                key: 'node.kubernetes.io/instance-type',
                operator: 'In',
                values: ['k3s'],
              }],
          },
        ],
      },
    },
  },
};

local pvc = {
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'feeds-pvc',
    namespace: 'feeds-to-pocket',
  },
  spec: {
    accessModes: [
      'ReadWriteOnce',
    ],
    storageClassName: '',
    volumeName: 'feeds-to-pocket-config',
    resources: {
      requests: {
        storage: '1Gi',
      },
    },
  },
};

[pv, pvc]
