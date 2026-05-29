output "github_oauth_token_id" {
  description = "The ID of the GitHub OAuth token used for VCS integration."
  value = var.github_oauth_token_id
}

output "hcp_terraform_management_workspace_id" {
  description = "The ID of the Terraform Cloud workspace for example-app-management."
  value = tfe_workspace.this.id
}
