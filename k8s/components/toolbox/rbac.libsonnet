local role = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    name: 'toolbox-rollout',
  },
  rules: [
    {
      apiGroups: ['apps'],
      resources: ['deployments', 'daemonsets'],
      verbs: ['list', 'watch', 'get', 'patch'],
    },
  ],
};

local binding = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: 'toolbox',
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: 'toolbox',
      namespace: 'toolbox',
    },
  ],
  roleRef: {
    kind: 'ClusterRole',
    name: 'toolbox-rollout',
    apiGroup: 'rbac.authorization.k8s.io',
  },
};

[role, binding]
