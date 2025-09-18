output "team_ids" {
  description = "IDs of created Secure teams keyed by name."
  value       = { for k, v in sysdig_secure_team.this : k => v.id }
}
