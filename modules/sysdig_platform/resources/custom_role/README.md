# sysdig_platform / resources / custom_role

Create Sysdig Platform custom roles.

## Inputs
- `roles` (list): objects with `name`, optional `description`, optional `permissions`.

## Example
```hcl
module "platform_custom_roles" {
  source = "../../modules/sysdig_platform/resources/custom_role"
  providers = { sysdig.platform = sysdig.platform }
  roles = [{ name = "readonly_analyst", permissions = ["read:users","read:teams"] }]
}
