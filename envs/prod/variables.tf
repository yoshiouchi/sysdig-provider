variable "sysdig_secure_url" {
  description = "Base URL for Secure (e.g., https://app.au1.sysdig.com)"
  type        = string
}

variable "sysdig_monitor_url" {
  description = "Base URL for Monitor (e.g., https://app.au1.sysdig.com)"
  type        = string
}

# Optional: keep region if you use it elsewhere
variable "region" {
  description = "Sysdig region (e.g., au1)"
  type        = string
  default     = "au1"
}

variable "platform_roles" {
  description = "Custom roles to create in Sysdig Platform"
  type = list(object({
    name                = string
    description         = optional(string)
    monitor_permissions = optional(list(string))
    secure_permissions  = optional(list(string))
  }))
  default = []
}

variable "secure_teams" {
  description = "Teams to create in Sysdig Secure"
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
  description = "Monitor Event v2 alerts to create"
  type = list(object({
    # Required
    name      = string
    filter    = string
    operator  = string
    threshold = number

    # Optional
    range_seconds = optional(number)
    severity      = optional(string)
    description   = optional(string)
    enabled       = optional(bool)
    group         = optional(string)
    sources       = optional(list(string))
    labels        = optional(map(string))

    scope = optional(list(object({
      label    = string
      operator = string
      values   = list(string)
    })))

    notification_channels = optional(list(object({
      id                     = number
      renotify_every_minutes = optional(number)
      notify_on_resolve      = optional(bool)
      main_threshold         = optional(bool)
      warning_threshold      = optional(bool)
    })))
  }))
  default = []
}
