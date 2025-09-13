resource "vault_pki_secret_backend_role" "lab-ingress-role" {
  backend = vault_mount.pki-lab-2026.path
  name    = "lab-ingress-role"
  max_ttl = vault_mount.pki-lab-2026.max_lease_ttl_seconds

  allowed_domains  = ["lab.home"]
  allow_subdomains = true
  require_cn       = true

  organization = ["EZ Homelab"]
  country      = ["US"]
  locality     = ["Seattle"]
  province     = ["WA"]
}

resource "vault_pki_secret_backend_role" "lab-internal-role" {
  backend = vault_mount.pki-lab-2026.path
  name    = "lab-internal-role"
  max_ttl = vault_mount.pki-lab-2026.max_lease_ttl_seconds

  allow_any_name = true
  require_cn     = true

  ou           = ["k3s"]
  organization = ["EZ Homelab"]
  country      = ["US"]
  locality     = ["Seattle"]
  province     = ["WA"]
}

