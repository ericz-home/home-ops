terraform {
  required_providers {
    pihole = {
      source  = "ryanwholey/pihole"
      version = "2.0.0-beta.1"
    }
  }
}

provider "pihole" {
  url = var.url # PIHOLE_URL

  # Experimental, requires Pi-hole Web Interface >= 5.11.0
  # api_token = var.api_token # PIHOLE_API_TOKEN
  password = var.api_token
}
