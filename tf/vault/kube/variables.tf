variable "services" {
  type        = map(list(string))
  description = "list of services that need access to secrets"
  default = {
    "homeassistant"   = ["homeassistant"],
    "tailscale"       = ["coredns", "operator"],
    "projectcontour"  = ["envoy"],
    "feeds-to-pocket" = ["feeds-to-pocket"],
    "toolbox"         = ["toolbox"]
  }
}
