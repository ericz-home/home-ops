local operator = {
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'splunk-operator-app-download',
    labels: {
      app: 'splunk-operator',
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
      path: '/home/home/Documents/work/k3s/storage/splunk/operator/apps',
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

local etc = {
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'splunk-etc',
    labels: {
      app: 'splunk',
    },
  },
  spec: {
    capacity: {
      storage: '10Gi',
    },
    volumeMode: 'Filesystem',
    accessModes: [
      'ReadWriteOnce',
    ],
    persistentVolumeReclaimPolicy: 'Retain',
    storageClassName: 'local-storage',
    'local': {
      path: '/home/home/Documents/work/k3s/storage/splunk/splunk/etc',
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

local var = {
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'splunk-var',
    labels: {
      app: 'splunk',
    },
  },
  spec: {
    capacity: {
      storage: '50Gi',
    },
    volumeMode: 'Filesystem',
    accessModes: [
      'ReadWriteOnce',
    ],
    persistentVolumeReclaimPolicy: 'Retain',
    storageClassName: 'local-storage',
    'local': {
      path: '/home/home/Documents/work/k3s/storage/splunk/splunk/var',
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

[operator, etc, var]
