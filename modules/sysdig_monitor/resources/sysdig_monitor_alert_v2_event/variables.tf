variable "alerts" {
  description = "Monitor Event v2 alerts to create."
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

    # singular 'scope'
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
