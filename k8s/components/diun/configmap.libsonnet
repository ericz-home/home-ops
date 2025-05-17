local cfg = importstr 'include/diun.yaml';

{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    namespace: 'diun',
    name: 'diun',
  },
  data: {
    'diun.yaml': cfg,
  },
}
