# Example shape; adjust to the real resource schema when we flesh it out
# (We’re matching the “Platform > Resources > custom_role” idea.)
resource "sysdig_custom_role" "this" {
  for_each    = { for r in var.roles : r.name => r }
  name        = each.value.name
  description = lookup(each.value, "description", null)
  permissions = lookup(each.value, "permissions", [])
}
