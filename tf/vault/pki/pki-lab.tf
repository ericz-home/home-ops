resource "vault_mount" "pki-lab-2024" {
  path        = "pki/lab/v2024"
  type        = "pki"
  description = "lab intermediate CA"

  # 24h
  default_lease_ttl_seconds = 86400
  # 1 year
  max_lease_ttl_seconds = 31536000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "lab_cert_2024" {
  depends_on   = [vault_mount.pki-lab-2024]
  backend      = vault_mount.pki-lab-2024.path
  type         = "internal"
  common_name  = "Lab intermediate CA 2024"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "lab intermediate"
  organization = "EZ Homelab"
  country      = "US"
  province     = "WA"
  locality     = "Seattle"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "lab_signed_cert_2024" {
  count = var.signed_cert_file == "" ? 0 : 1

  depends_on  = [vault_mount.pki-lab-2024]
  backend     = vault_mount.pki-lab-2024.path
  certificate = file("${var.signed_cert_file}")
}

resource "vault_pki_secret_backend_role" "lab-ingress-role" {
  backend = vault_mount.pki-lab-2025.path
  name    = "lab-ingress-role"
  max_ttl = vault_mount.pki-lab-2025.max_lease_ttl_seconds

  allowed_domains  = ["lab.home"]
  allow_subdomains = true
  require_cn       = true

  organization = ["EZ Homelab"]
  country      = ["US"]
  locality     = ["Seattle"]
  province     = ["WA"]
}

resource "vault_pki_secret_backend_role" "lab-internal-role" {
  backend = vault_mount.pki-lab-2025.path
  name    = "lab-internal-role"
  max_ttl = vault_mount.pki-lab-2025.max_lease_ttl_seconds

  allow_any_name = true
  require_cn     = true

  ou           = ["k3s"]
  organization = ["EZ Homelab"]
  country      = ["US"]
  locality     = ["Seattle"]
  province     = ["WA"]
}

