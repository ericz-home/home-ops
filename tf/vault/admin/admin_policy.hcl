# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "patch", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# read default policy
path "sys/policy/default"
{
  capabilities = ["read"]
}

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
}

# List, create, update, and delete key/value secrets
path "secrets/*"
{
  capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
}

path "pki/*"
{
  capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
}

# To create an entity and entity alias. Enable and configure Vault as an OIDC provider
path "identity/*" {
  capabilities = [ "create", "read", "update", "patch", "delete", "list" ]
}

# allow updating entity itself
path "identity/entity/id/{{identity.entity.id}}" {
  capabilities = [ "read", "update", "patch" ]
}


# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}


