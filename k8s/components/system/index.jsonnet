{
  apiVersion: 'storage.k8s.io/v1',
  kind: 'StorageClass',
  metadata: {
    name: 'local-storage',
    namespace: 'lab-system',
  },
  provisioner: 'kubernetes.io/no-provisioner',
  volumeBindingMode: 'WaitForFirstConsumer',
  reclaimPolicy: 'Retain',
}
