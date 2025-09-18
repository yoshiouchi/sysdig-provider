module "platform_custom_roles" {
  source = "../../modules/sysdig_platform/resources/custom_role" # we'll add this next
  providers = {
    sysdig.platform = sysdig.platform
  }

  # example inputs
  roles = [
    {
      name        = "readonly_analyst"
      description = "Read-only access for analysts"
      permissions = ["read:users", "read:teams"]
    }
  ]
}
