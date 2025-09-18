variable "roles" {
  description = "List of custom roles to create"
  type = list(object({
    name        : string
    description : optional(string)
    permissions : optional(list(string))
  }))
  default = []
}
