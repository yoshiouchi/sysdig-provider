terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "yoshiouchi"
    workspaces {
      name    = "sysdig-provider-dev"
      project = "Sysdig Provider" # <-- goes here
    }
  }
}
