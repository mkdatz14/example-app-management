resource "tfe_workspace" "example_app_management" {
  name = "example-app-management"
  organization = local.organization_name
  description = "Terraform Cloud workspace for managing the example-app application."

  vcs_repo {
    identifier     = "mkdatz/example-app-management"
    oauth_token_id = var.github_oauth_token_id
    branch         = "main"
  }

  auto_apply = true
}

locals {
    example_app_envs = {
        dev = {
            auto_apply = true
            working_directory = "envs/dev"
            description = "Development environment for example-app- VCS triggers enabled, auto-apply enabled."
        }
        staging = {
            auto_apply = false
            working_directory = "envs/staging"
            description = "Staging environment for example-app- VCS triggers enabled, auto-apply disabled."
        }
        prod = {
            auto_apply = false
            working_directory = "envs/prod"
            description = "Production environment for example-app- VCS triggers enabled, auto-apply disabled."
        }
    }
}

resource "tfe_workspace" "example_app" {
    for_each = local.example_app_envs
    name = "example-app-${each.key}"
    organization = local.organization_name
    description = each.value.description
    working_directory = each.value.working_directory

    vcs_repo {
        identifier     = "mkdatz/example-app"
        oauth_token_id = var.github_oauth_token_id
        branch         = "main"
    }

    auto_apply = each.value.auto_apply
    file_triggers_enabled = true
    trigger_prefixes = ["envs/${each.key}/**", "shared/**"]
}

resource "tfe_variable" "example_app_plan_args" {
    for_each = local.example_app_envs

    key = "TF_CLI_ARGS_plan"
    value = "-var-file=envs/${each.key}/terraform.tfvars"
    category = "env"
    workspace_id = tfe_workspace.example_app[each.key].id
}

resource "tfe_variable" "example_app_apply_args" {
    for_each = local.example_app_envs

    key = "TF_CLI_ARGS_apply"
    value = "-var-file=envs/${each.key}/terraform.tfvars"
    category = "env"
    workspace_id = tfe_workspace.example_app[each.key].id
}
