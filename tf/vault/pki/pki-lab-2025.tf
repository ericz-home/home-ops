resource "vault_mount" "pki-lab-2025" {
  path        = "pki/lab/v2025"
  type        = "pki"
  description = "lab intermediate CA 2025"

  # 24h
  default_lease_ttl_seconds = 86400
  # 1 year
  max_lease_ttl_seconds = 31536000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "lab_cert_2025" {
  depends_on   = [vault_mount.pki-lab-2025]
  backend      = vault_mount.pki-lab-2025.path
  type         = "internal"
  common_name  = "Lab intermediate CA 2025"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "Lab Intermediate"
  organization = "EZ Homelab"
  country      = "US"
  province     = "WA"
  locality     = "Seattle"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "lab_signed_cert_2025" {
  count = var.signed_cert_file == "" ? 0 : 1

  depends_on  = [vault_mount.pki-lab-2025]
  backend     = vault_mount.pki-lab-2025.path
  certificate = file("${var.signed_cert_file}")
}
