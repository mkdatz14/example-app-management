provider "tfe" {
  hostname     = var.tfe_hostname
  organization = var.organization_name
  token        = var.tfe_token
}

locals {
  workspaces = {
    dev = {
      name              = "example-app-dev"
      working_directory = "envs/dev"
      trigger_patterns  = ["envs/dev/**", "shared/**", "modules/**"]
    }
    staging = {
      name              = "example-app-staging"
      working_directory = "envs/staging"
      trigger_patterns  = ["envs/staging/**", "shared/**", "modules/**"]
    }
    prod = {
      name              = "example-app-prod"
      working_directory = "envs/prod"
      trigger_patterns  = ["envs/prod/**", "shared/**", "modules/**"]
    }
  }

  workspace_variable_entries = {
    for item in flatten([
      for workspace_name, variables in var.workspace_variables : [
        for key, config in variables : {
          workspace_name = workspace_name
          key            = key
          value          = config.value
          category       = config.category
          hcl            = config.hcl
          sensitive      = config.sensitive
        }
      ]
    ]) : "${item.workspace_name}:${item.key}" => item
  }
}

resource "tfe_project" "this" {
  organization = var.organization_name
  name         = var.project_name
}

resource "tfe_workspace" "this" {
  for_each = local.workspaces

  organization          = var.organization_name
  project_id            = tfe_project.this.id
  name                  = each.value.name
  working_directory     = each.value.working_directory
  file_triggers_enabled = true
  queue_all_runs        = true
  trigger_patterns      = each.value.trigger_patterns

  vcs_repo {
    branch         = var.vcs_branch
    identifier     = var.vcs_repository_identifier
    oauth_token_id = var.vcs_oauth_token_id
  }
}

resource "tfe_variable" "workspace" {
  for_each = local.workspace_variable_entries

  workspace_id = tfe_workspace.this[each.value.workspace_name].id
  key          = each.value.key
  value        = each.value.value
  category     = each.value.category
  hcl          = each.value.hcl
  sensitive    = each.value.sensitive
}