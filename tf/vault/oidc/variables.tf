variable "admin_user" {
  description = "admin username"
  type        = string
}

variable "clients" {
  description = "list of oidc clients"
  type = list(object({
    name          = string
    redirect_uris = list(string)
    allow_users   = bool
    client_type   = string
  }))
}

