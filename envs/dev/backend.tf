terraform {
  backend "local" {
    path = "terraform.tfstate" # optional; default is terraform.tfstate in this folder
  }
}
