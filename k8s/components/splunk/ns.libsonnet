{
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    labels: {
      'control-plane': 'controller-manager',
      'lab.home/gateway': 'splunk',
    },
    name: 'splunk',
  },
}
