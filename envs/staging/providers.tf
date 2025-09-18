terraform {
  required_version = ">= 1.6.0"
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = "~> 1.0"
    }
  }
}

provider "sysdig" { alias = "secure" }
provider "sysdig" { alias = "monitor" }
provider "sysdig" { alias = "platform" }
