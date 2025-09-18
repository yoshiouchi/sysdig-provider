# Creates one or more custom roles in Sysdig Platform.
# Each object in var.roles becomes a sysdig_custom_role.
resource "sysdig_custom_role" "this" {
  for_each    = { for r in var.roles : r.name => r }
  name        = each.value.name
  description = try(each.value.description, null)
  permissions = try(each.value.permissions, [])
}
