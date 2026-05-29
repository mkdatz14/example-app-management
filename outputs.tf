output "hcp_terraform_management_workspace_id" {
  description = "The ID of the Terraform Cloud workspace for example-app-management."
  value = tfe_workspace.example_app_management.id
}
