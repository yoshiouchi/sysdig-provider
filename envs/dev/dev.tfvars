region       = "au1"
# Region endpoints (AU1 Sydney)
sysdig_secure_url  = "https://app.au1.sysdig.com"
sysdig_monitor_url = "https://app.au1.sysdig.com"

platform_roles = [
  {
    name                = "readonly_analyst"
    description         = "Read-only access for analysts"
    monitor_permissions = ["kubernetes-api-commands.read"]
    secure_permissions  = ["scanning.read"]
  }
]

secure_teams = [
  {
    name        = "platform"
    description = "Platform engineering team"
    # custom_role_id can be set after the role exists (output from the platform module)
  }
]

monitor_event_alerts = [
  {
    name          = "K8s: Failed to pull image"
    description   = "Raise when image pull failures occur"
    severity      = "Medium"
    filter        = "kubernetes.event.reason = 'Failed to pull image'"
    operator      = ">"
    threshold     = 0
    range_seconds = 600

    scope = [
      {
        label    = "kube_cluster_name"
        operator = "in"
        values   = ["YOUR-CLUSTER"]
      }
    ]
    # notification_channels = [{ id = 1234 }]
  }
]
# CI test: no-op change to trigger plan
