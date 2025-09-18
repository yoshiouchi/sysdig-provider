output "role_ids" {
  description = "IDs of the created custom roles keyed by name."
  value       = { for k, v in sysdig_custom_role.this : k => v.id }
}
