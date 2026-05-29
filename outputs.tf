output "project_id" {
  value = tfe_project.this.id
}

output "workspace_ids" {
  value = {
    for key, workspace in tfe_workspace.this : key => workspace.id
  }
}

output "workspace_names" {
  value = {
    for key, workspace in tfe_workspace.this : key => workspace.name
  }
}

output "workspace_urls" {
  value = {
    for key, workspace in tfe_workspace.this : key => workspace.html_url
  }
}