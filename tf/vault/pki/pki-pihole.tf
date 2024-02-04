resource "vault_pki_secret_backend_role" "pihole-role" {
  backend = vault_mount.pki-lab-2024.path
  name    = "pihole-role"
  max_ttl = vault_mount.pki-lab-2024.max_lease_ttl_seconds
  ttl     = 7776000 // 90d 

  allowed_domains    = ["raspberrypi.home", "pi.hole"]
  allow_subdomains   = false
  allow_bare_domains = true
  require_cn         = true

  organization = ["EZ Homelab"]
  ou           = ["RaspberryPi"]
  country      = ["US"]
  locality     = ["Seattle"]
  province     = ["WA"]
}
