local pv = {
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'mqtt-data',
    labels: {
      app: 'mqtt',
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
      path: '/home/home/Documents/work/k3s/storage/mqtt',
    },
    claimRef: {
      name: 'mqtt-pvc',
      namespace: 'mqtt',
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
    name: 'mqtt-pvc',
    namespace: 'mqtt',
  },
  spec: {
    accessModes: [
      'ReadWriteOnce',
    ],
    storageClassName: '',
    volumeName: 'mqtt-data',
    resources: {
      requests: {
        storage: '1Gi',
      },
    },
  },
};

[pv, pvc]
