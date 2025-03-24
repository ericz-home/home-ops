resource "vault_identity_oidc_key" "oidc_key" {
  name               = "lab-oidc-key"
  allowed_client_ids = ["*"]
}

resource "vault_identity_oidc_scope" "profile" {
  name     = "profile"
  template = "{ \"username\": {{identity.entity.name}}, \"email\": {{identity.entity.metadata.email}}, \"display_name\": {{identity.entity.metadata.display_name}} }"
}

resource "vault_identity_oidc_scope" "user" {
  name     = "user"
  template = "{ \"username\": {{identity.entity.name}} }"
}

resource "vault_identity_oidc_scope" "email" {
  name     = "email"
  template = "{ \"email\": {{identity.entity.metadata.email}} }"
}

resource "vault_identity_oidc_scope" "groups" {
  name     = "groups"
  template = "{ \"groups\": {{identity.entity.groups.names}} }"
}

resource "vault_identity_oidc_scope" "roles" {
  name     = "roles"
  template = "{ \"roles\": {{identity.entity.groups.names}} }"
}

resource "vault_identity_oidc_provider" "oidc_provider" {
  name               = "lab-oidc-provider"
  https_enabled      = true
  issuer_host        = "vault.lab.home:4443"
  allowed_client_ids = [for c in vault_identity_oidc_client.oidc_clients : c.client_id]
  scopes_supported = [
    vault_identity_oidc_scope.groups.name,
    vault_identity_oidc_scope.user.name,
    vault_identity_oidc_scope.profile.name,
    vault_identity_oidc_scope.email.name,
    vault_identity_oidc_scope.roles.name,
  ]
}

output "issuer" {
  value = vault_identity_oidc_provider.oidc_provider.issuer
}
