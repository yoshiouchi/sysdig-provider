terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "yoshiouchi"
    workspaces { name = "sysdig-prod" }
  }
}
