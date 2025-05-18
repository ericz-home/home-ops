local pv_config = {
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'homeassistant-config',
    labels: {
      app: 'homeassistant',
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
      path: '/home/home/Documents/work/k3s/storage/homeassistant/config',
    },
    claimRef: {
      name: 'config-pvc',
      namespace: 'homeassistant',
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

local pv_backup = {
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'homeassistant-backup',
    labels: {
      app: 'homeassistant',
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
      path: '/mnt/backups/homeassistant',
    },
    claimRef: {
      name: 'backup-pvc',
      namespace: 'homeassistant',
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

local pv_esphome = {
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'esphome',
    labels: {
      app: 'esphome',
    },
  },
  spec: {
    capacity: {
      storage: '2Gi',
    },
    volumeMode: 'Filesystem',
    accessModes: [
      'ReadWriteOnce',
    ],
    persistentVolumeReclaimPolicy: 'Retain',
    storageClassName: 'local-storage',
    'local': {
      path: '/home/home/Documents/work/k3s/storage/homeassistant/esphome',
    },
    claimRef: {
      name: 'esphome-pvc',
      namespace: 'homeassistant',
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

local pvc_config = {
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'config-pvc',
    namespace: 'homeassistant',
  },
  spec: {
    accessModes: [
      'ReadWriteOnce',
    ],
    storageClassName: '',
    volumeName: 'homeassistant-config',
    resources: {
      requests: {
        storage: '10Gi',
      },
    },
  },
};

local pvc_backup = {
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'backup-pvc',
    namespace: 'homeassistant',
  },
  spec: {
    accessModes: [
      'ReadWriteOnce',
    ],
    storageClassName: '',
    volumeName: 'homeassistant-backup',
    resources: {
      requests: {
        storage: '10Gi',
      },
    },
  },
};

local pvc_esphome = {
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'esphome-pvc',
    namespace: 'homeassistant',
  },
  spec: {
    accessModes: [
      'ReadWriteOnce',
    ],
    storageClassName: '',
    volumeName: 'esphome',
    resources: {
      requests: {
        storage: '2Gi',
      },
    },
  },
};
[pv_config, pv_backup, pv_esphome, pvc_config, pvc_backup, pvc_esphome]
