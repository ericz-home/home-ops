variable "services" {
  type        = map(list(string))
  description = "list of services that need access to secrets"
  default = {
    "homeassistant"  = ["homeassistant"],
    "tailscale"      = ["tailscale"],
    "projectcontour" = ["envoy"],
  }
}
