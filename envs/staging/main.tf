# PLATFORM: custom roles
module "platform_custom_roles" {
  source    = "../../modules/sysdig_platform/resources/sysdig_custom_role"
  providers = { sysdig = sysdig.platform }

  roles = var.platform_roles
}

# SECURE: teams (optionally wire custom_role_id from platform output)
module "secure_teams" {
  source    = "../../modules/sysdig_secure/resources/sysdig_secure_team"
  providers = { sysdig = sysdig.secure }

  teams = [
    for t in var.secure_teams : merge(t, {
      # true if the item explicitly sets default=true
      # OR if it matches the env-level default_team name
      default = (t.default == true) || (var.default_team != null && t.name == var.default_team)
    })
  ]
}

# MONITOR: event-based alerts
module "monitor_event_alerts" {
  source    = "../../modules/sysdig_monitor/resources/sysdig_monitor_alert_v2_event"
  providers = { sysdig = sysdig.monitor }
  alerts    = var.monitor_event_alerts
}

output "platform_role_ids" {
  value = module.platform_custom_roles.role_ids
}
output "secure_team_ids" {
  value = module.secure_teams.team_ids
}
output "monitor_alert_ids" {
  value = module.monitor_event_alerts.alert_ids
}
