terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "yoshiouchi"
    workspaces {
      name    = "sysdig-provider-prod"
      project = "Sysdig Provider"
    }
  }
}
