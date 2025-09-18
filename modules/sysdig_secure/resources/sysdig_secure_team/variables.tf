variable "teams" {
  description = "Teams to create in Secure."
  type = list(object({
    name           = string
    description    = optional(string)
    default        = optional(bool)
    theme          = optional(string)
    custom_role_id = optional(string)
  }))
  default = []
}
