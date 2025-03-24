data "vault_identity_entity" "admin_entity" {
  entity_name = var.admin_user
}

data "vault_identity_group" "admin_group" {
  group_name = "admins"
}

data "vault_identity_group" "users_group" {
  group_name = "users"
}

resource "vault_identity_oidc_assignment" "admin_assignment" {
  name = "admin_assignment"
  entity_ids = [
    data.vault_identity_entity.admin_entity.id
  ]
  group_ids = [
    data.vault_identity_group.admin_group.id
  ]
}

resource "vault_identity_oidc_assignment" "users_assignment" {
  name = "users_assignment"
  group_ids = [
    data.vault_identity_group.users_group.id
  ]
}


