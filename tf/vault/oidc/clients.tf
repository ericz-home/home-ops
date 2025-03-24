resource "vault_identity_oidc_client" "oidc_clients" {
  count = length(var.clients)

  name          = var.clients[count.index].name
  key           = vault_identity_oidc_key.oidc_key.name
  redirect_uris = var.clients[count.index].redirect_uris
  assignments = concat(
    [vault_identity_oidc_assignment.admin_assignment.name],
    var.clients[count.index].allow_users ?
    [vault_identity_oidc_assignment.users_assignment.name] : []
  )
  id_token_ttl     = "14400"
  access_token_ttl = "43200"
  client_type      = var.clients[count.index].client_type
}

