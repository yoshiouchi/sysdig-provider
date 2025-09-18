variable "roles" {
  description = "List of custom roles to create."
  type = list(object({
    name                = string
    description         = optional(string)
    monitor_permissions = optional(list(string))
    secure_permissions  = optional(list(string))
  }))
  default = []
}
