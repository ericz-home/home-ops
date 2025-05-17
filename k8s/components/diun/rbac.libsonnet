local sa = {
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    namespace: 'diun',
    name: 'diun',
  },
};


local clusterRole = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    name: 'diun',
  },
  rules: [
    {
      apiGroups: [''],
      resources: ['pods'],
      verbs: ['get', 'watch', 'list'],
    },
  ],
};

local clusterRoleBinding = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: 'diun',
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: 'diun',
      namespace: 'diun',
    },
  ],
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'ClusterRole',
    name: 'diun',
  },
};

[sa, clusterRole, clusterRoleBinding]
