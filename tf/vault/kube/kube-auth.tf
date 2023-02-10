resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kube_config" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://10.43.0.1:443"
}

