variable "tfe_hostname" {
  type    = string
  default = "app.terraform.io"
}

variable "github_oauth_token_id" {
  type        = string
  description = "The ID of the GitHub OAuth token used for VCS integration."
}
