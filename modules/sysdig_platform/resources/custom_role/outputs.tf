output "role_ids" {
  description = "IDs of created custom roles"
  value       = { for k, v in sysdig_custom_role.this : k => v.id }
}
