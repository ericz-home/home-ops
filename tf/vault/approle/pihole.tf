resource "vault_policy" "pihole_issuer_policy" {
  name = "pihole_issuer_policy"

  policy = <<EOF
path "pki/lab/+/issue/pihole-role" {
  capabilities = ["create", "update", "read"]
}
EOF
}

resource "vault_approle_auth_backend_role" "pihole" {
  backend        = vault_auth_backend.approle.path
  role_name      = "pihole-role"
  token_policies = [vault_policy.pihole_issuer_policy.name]
  token_ttl      = 3600  // 1h
  token_max_ttl  = 86400 // 24h

  secret_id_bound_cidrs = ["10.42.0.242/32", "192.168.0.0/16", "100.124.168.96/32"]
  token_bound_cidrs     = ["10.42.0.242/32", "192.168.0.0/16", "100.124.168.96/32"]
}
