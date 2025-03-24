variable "bootstrap" {
  type    = bool
  default = false
}

variable "admin" {
  description = "admin"
  type = object({
    username     = string
    display_name = string
  })
}

variable "users" {
  description = "map of users"
  type = list(object({
    username     = string
    display_name = string
  }))
}

variable "passwords" {
  description = "passwords for users"
  type        = map(string)
}
