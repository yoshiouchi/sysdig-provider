terraform {
  required_providers {
    sysdig = {
      source = "sysdiglabs/sysdig"
      # no version pin here; pin at the root/env
    }
  }
}
