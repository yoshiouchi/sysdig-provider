variable "region" {
  description = "Sysdig region (e.g., au1)"
  type        = string
}

variable "org_name" {
  description = "Org name for naming/tags (optional)"
  type        = string
  default     = null
}

variable "default_team" {
  description = "If set, name of the Secure team to mark as default (optional)"
  type        = string
  default     = null
}

variable "sysdig_secure_url" {
  description = "https://app.au1.sysdig.com (AU1 example)"
  type        = string
}

variable "sysdig_monitor_url" {
  description = "https://app.au1.sysdig.com (AU1 example)"
  type        = string
}

# Module inputs (or move these into per-module tfvars if you prefer)
variable "platform_roles" {
  type = list(object({
    name                = string
    description         = optional(string)
    monitor_permissions = optional(list(string))
    secure_permissions  = optional(list(string))
  }))
  default = []
}

variable "secure_teams" {
  type = list(object({
    name           = string
    description    = optional(string)
    default        = optional(bool)
    theme          = optional(string)
    custom_role_id = optional(string)
  }))
  default = []
}

variable "monitor_event_alerts" {
  description = "Monitor Event v2 alerts to create."
  type = list(object({
    # Required
    name      = string
    filter    = string
    operator  = string
    threshold = number

    # Recommended / optional (defaults are set inside the module)
    range_seconds = optional(number)
    severity      = optional(string)
    description   = optional(string)
    enabled       = optional(bool)
    group         = optional(string)
    group_by      = optional(list(string))
    sources       = optional(list(string))
    labels        = optional(map(string))

    notification_channels = optional(list(object({
      id                     = number
      renotify_every_minutes = optional(number)
      notify_on_resolve      = optional(bool)
      main_threshold         = optional(bool)
      warning_threshold      = optional(bool)
    })))

    scopes = optional(list(object({
      label    = string
      operator = string
      values   = list(string)
    })))
  }))
  default = []
}