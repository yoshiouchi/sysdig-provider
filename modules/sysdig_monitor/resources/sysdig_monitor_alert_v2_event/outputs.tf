output "alert_ids" {
  description = "IDs of created Monitor alerts keyed by name."
  value       = { for k, v in sysdig_monitor_alert_v2_event.this : k => v.id }
}
