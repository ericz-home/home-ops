resource "vault_mount" "pki-lab-2026" {
  path        = "pki/lab/v2026"
  type        = "pki"
  description = "lab intermediate CA 2026"

  # 24h
  default_lease_ttl_seconds = 86400
  # 1 year
  max_lease_ttl_seconds = 31536000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "lab_cert_2026" {
  depends_on   = [vault_mount.pki-lab-2026]
  backend      = vault_mount.pki-lab-2026.path
  type         = "internal"
  common_name  = "Lab intermediate CA 2026"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "Lab Intermediate"
  organization = "EZ Homelab"
  country      = "US"
  province     = "WA"
  locality     = "Seattle"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "lab_signed_cert_2026" {
  count = var.signed_cert_file == "" ? 0 : 1

  depends_on  = [vault_mount.pki-lab-2026]
  backend     = vault_mount.pki-lab-2026.path
  certificate = file("${var.signed_cert_file}")
}
