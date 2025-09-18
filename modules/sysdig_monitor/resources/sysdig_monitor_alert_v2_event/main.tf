resource "sysdig_monitor_alert_v2_event" "this" {
  for_each = { for a in var.alerts : a.name => a }

  # Required
  name      = each.value.name
  filter    = each.value.filter
  operator  = each.value.operator
  threshold = each.value.threshold

  # Optional (safe defaults)
  description   = try(each.value.description, null)
  enabled       = try(each.value.enabled, true)
  range_seconds = try(each.value.range_seconds, 600)
  severity      = try(each.value.severity, "Low") # "High" | "Medium" | "Low" | "Info"
  group         = try(each.value.group, null)
  sources       = try(each.value.sources, null) # list(string)
  labels        = try(each.value.labels, null)  # map(string)

  # Repeated block: notification_channels
  dynamic "notification_channels" {
    for_each = coalesce(each.value.notification_channels, [])
    content {
      id                     = notification_channels.value.id
      renotify_every_minutes = try(notification_channels.value.renotify_every_minutes, null)
      notify_on_resolve      = try(notification_channels.value.notify_on_resolve, null)
      main_threshold         = try(notification_channels.value.main_threshold, null)
      warning_threshold      = try(notification_channels.value.warning_threshold, null)
    }
  }

  # Repeated block: scope
  dynamic "scope" {
    for_each = coalesce(each.value.scope, [])
    content {
      label    = scope.value.label
      operator = scope.value.operator # equals | notEquals | in | notIn | contains | notContains | startsWith
      values   = scope.value.values
    }
  }
}
