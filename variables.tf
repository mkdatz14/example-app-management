variable "tfe_hostname" {
  type    = string
  default = "app.terraform.io"
}

variable "tfe_token" {
  type      = string
  default   = null
  nullable  = true
  sensitive = true
}

variable "organization_name" {
  type    = string
  default = "my-organization"
}

variable "project_name" {
  type    = string
  default = "example-app"
}

variable "vcs_repository_identifier" {
  type = string
}

variable "vcs_oauth_token_id" {
  type = string
}

variable "vcs_branch" {
  type    = string
  default = "main"
}

variable "workspace_variables" {
  type = map(map(object({
    value     = string
    category  = optional(string, "terraform")
    hcl       = optional(bool, false)
    sensitive = optional(bool, false)
  })))
  default = {}
}