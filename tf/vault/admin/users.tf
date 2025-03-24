resource "vault_policy" "user_policy" {
  name   = "user"
  policy = file("user_policy.hcl")
}

resource "vault_generic_endpoint" "users" {
  count = length(var.users)

  depends_on = [vault_auth_backend.userpass]

  path                 = "auth/userpass/users/${var.users[count.index].username}"
  ignore_absent_fields = true

  data_json = jsonencode({
    "password" : var.passwords["${var.users[count.index].username}"]
  })
}

resource "vault_identity_entity" "user_entities" {
  count = length(var.users)

  name = var.users[count.index].username
  metadata = {
    email        = "${var.users[count.index].username}@lab.home"
    display_name = "${var.users[count.index].display_name}"
  }
}

resource "vault_identity_entity_alias" "user_entity_aliases" {
  count = length(var.users)

  depends_on = [vault_auth_backend.userpass, vault_identity_entity.user_entities]

  name           = var.users[count.index].username
  canonical_id   = vault_identity_entity.user_entities[count.index].id
  mount_accessor = vault_auth_backend.userpass.accessor
}

resource "vault_identity_group" "users_group" {
  depends_on = [vault_auth_backend.userpass, vault_identity_entity.user_entities]

  name              = "users"
  type              = "internal"
  policies          = [vault_policy.user_policy.name]
  member_entity_ids = [for u in vault_identity_entity.user_entities : u.id]
}
