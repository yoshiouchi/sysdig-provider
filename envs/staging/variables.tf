variable "region"       { description = "Sysdig region (e.g., au1)"; type = string }
variable "org_name"     { description = "Org name for naming/tags";  type = string }
variable "default_team" { description = "Default team";              type = string }
variable "sysdig_secure_url"  { description = "Base URL for Secure (e.g., https://app.au1.sysdig.com)"; type = string }
variable "sysdig_monitor_url" { description = "Base URL for Monitor (e.g., https://app.au1.sysdig.com)"; type = string }
