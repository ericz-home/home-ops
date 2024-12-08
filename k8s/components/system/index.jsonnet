[
  // RBAC for user login
  {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'ClusterRoleBinding',
    metadata: {
      name: 'oidc-cluster-admin',
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'ClusterRole',
      name: 'cluster-admin',
    },
    subjects: [
      {
        apiGroup: 'rbac.authorization.k8s.io',
        kind: 'Group',
        name: 'oidc:kube_admins',
      },
    ],
  },
  // Namespace for terraform state files
  {
    apiVersion: 'v1',
    kind: 'Namespace',
    metadata: {
      name: 'terraform',
    },
  },
]
