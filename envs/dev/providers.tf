terraform {
  required_version = ">= 1.6.0"
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = "~> 1.0"
    }
  }
}

# Secure alias — uses token from SYSDIG_SECURE_API_TOKEN
provider "sysdig" {
  alias             = "secure"
  sysdig_secure_url = var.sysdig_secure_url
}

# Monitor alias — uses token from SYSDIG_MONITOR_API_TOKEN
provider "sysdig" {
  alias              = "monitor"
  sysdig_monitor_url = var.sysdig_monitor_url
}

# Platform alias — RBAC/“platform” features live under the same org base.
# Start by pointing at Secure’s URL/token. If a specific resource requires
# Monitor, you can re-point this alias in that env.
provider "sysdig" {
  alias                    = "platform"
  sysdig_secure_url        = var.sysdig_secure_url
  sysdig_secure_api_token  = var.sysdig_secure_api_token
  # intentionally NOT setting monitor here
}
