terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "yoshiouchi"
    workspaces {
      name    = "sysdig-provider-staging"
      project = "Sysdig Provider"
    }
  }
}
