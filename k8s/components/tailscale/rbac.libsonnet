local role = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: 'coredns',
    namespace: 'tailscale',
  },
  rules: [
    {
      apiGroups: [''],  // indicates the core API group
      resources: ['secrets'],
      verbs: ['create'],  // create cannot be restricted to a resource name
    },
    {
      apiGroups: [''],  // indicates the core API group
      resources: ['secrets'],
      resourceNames: ['coredns-auth'],
      verbs: ['get', 'update', 'patch'],  // create cannot be restricted to a resource name
    },
  ],
};

local binding = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: 'coredns',
    namespace: 'tailscale',
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: 'coredns',
    },
  ],
  roleRef: {
    kind: 'Role',
    name: 'coredns',
    apiGroup: 'rbac.authorization.k8s.io',
  },
};

[role, binding]
