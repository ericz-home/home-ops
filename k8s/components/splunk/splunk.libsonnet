{
  apiVersion: 'enterprise.splunk.com/v4',
  kind: 'Standalone',
  metadata: {
    name: 'splunk',
    namespace: 'splunk',
    labels: {
      app: 'splunk',
    },
  },
  spec: {
    serviceTemplate: {
      spec: {
        type: 'ClusterIP',
      },
    },
    etcVolumeStorageConfig: {
      storageClassName: 'local-storage',
      storageCapacity: '10Gi',
    },
    varVolumeStorageConfig: {
      storageClassName: 'local-storage',
      storageCapacity: '50Gi',
    },
  },
}
