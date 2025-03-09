resource "vault_identity_oidc_assignment" "open_webui_assignment" {
  name = "open_webui_assignment"
  entity_ids = [
    data.vault_identity_entity.admin_entity.id
  ]
  group_ids = [
    data.vault_identity_group.admin_group.id
  ]
}

resource "vault_identity_oidc_client" "open_webui" {
  name = "open_webui"
  key  = vault_identity_oidc_key.oidc_key.name
  redirect_uris = [
    "https://open-webui.lab.home:4443/oauth/oidc/callback",
    "http://open-webui.open-webui.svc.cluster.local:80/oauth/oidc/callback",
    "http://localhost:8080/oauth/oidc/callback",
  ]
  assignments = [
    vault_identity_oidc_assignment.open_webui_assignment.name
  ]
  id_token_ttl     = "14400"
  access_token_ttl = "43200"
  client_type      = "confidential"
}
