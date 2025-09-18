# Minimal team creation in Sysdig Secure
resource "sysdig_secure_team" "this" {
  for_each = { for t in var.teams : t.name => t }

  name        = each.value.name
  description = try(each.value.description, null)

  # Optional examples; uncomment if you need them in your org
  # default          = try(each.value.default, false)
  # theme            = try(each.value.theme, null)
  # custom_role_id   = try(each.value.custom_role_id, null) # can reference sysdig_custom_role
}
