resource "vault_pki_secret_backend_role" "unifi-role" {
  backend = vault_mount.pki-lab-2025.path
  name    = "unifi-role"
  max_ttl = vault_mount.pki-lab-2025.max_lease_ttl_seconds
  ttl     = 31536000 // 365d 

  allowed_domains    = ["unifi.home", "unifi"]
  allow_subdomains   = false
  allow_bare_domains = true
  require_cn         = true

  organization = ["EZ Homelab"]
  ou           = ["Unifi"]
  country      = ["US"]
  locality     = ["Seattle"]
  province     = ["WA"]
}

