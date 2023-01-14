resource "vault_policy" "admin_policy" {
  name   = "admins"
  policy = file("admin_policy.hcl")
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "admin_user" {
  depends_on = [vault_auth_backend.userpass]

  path                 = "auth/userpass/users/${var.admin_user}"
  ignore_absent_fields = true

  data_json = jsonencode({
    "password" : var.admin_password
  })
}

resource "vault_identity_entity" "admin_entity" {
  name = var.admin_user
}

resource "vault_identity_entity_alias" "admin_entity_alias" {
  depends_on = [vault_auth_backend.userpass, vault_identity_entity.admin_entity]

  name           = var.admin_user
  canonical_id   = vault_identity_entity.admin_entity.id
  mount_accessor = vault_auth_backend.userpass.accessor
}

resource "vault_identity_group" "admin_group" {
  depends_on = [vault_auth_backend.userpass, vault_identity_entity.admin_entity]

  name              = "admins"
  type              = "internal"
  policies          = [vault_policy.admin_policy.name]
  member_entity_ids = [vault_identity_entity.admin_entity.id]
}
