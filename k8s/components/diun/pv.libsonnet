local pv = {
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'diun-data',
    labels: {
      app: 'diun',
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
      path: '/home/home/Documents/work/k3s/storage/diun',
    },
    claimRef: {
      name: 'diun-pvc',
      namespace: 'diun',
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
    name: 'diun-pvc',
    namespace: 'diun',
  },
  spec: {
    accessModes: [
      'ReadWriteOnce',
    ],
    storageClassName: '',
    volumeName: 'diun-data',
    resources: {
      requests: {
        storage: '1Gi',
      },
    },
  },
};

[pv, pvc]
