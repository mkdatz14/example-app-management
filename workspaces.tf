resource "tfe_workspace" "example_app_management" {
  name = "example-app-management"
  organization = local.organization_name
  description = "Terraform Cloud workspace for managing the example-app application."

  vcs_repo {
    identifier     = "mkdatz14/example-app-management"
    oauth_token_id = var.github_oauth_token_id
    branch         = "main"
  }

  auto_apply = true
}

locals {
    example_app_tiers = {
        dev = {
            auto_apply = false
            description_prefix = "Development"
        }
        staging = {
            auto_apply = false
            description_prefix = "Staging"
        }
        prod = {
            auto_apply = false
            description_prefix = "Production"
        }
    }

    example_app_envs = merge([
        for tier, config in local.example_app_tiers : {
            for index in range(1, 4) : "${tier}-${index}" => {
                auto_apply = config.auto_apply
                working_directory = "envs/${tier}/${tier}-${index}"
                description = "${config.description_prefix} environment ${index} for example-app. VCS triggers enabled, auto-apply disabled."
                trigger_prefixes = ["envs/${tier}/${tier}-${index}/**", "shared/**"]
            }
        }
    ]...)
}

resource "tfe_workspace" "example_app" {
    for_each = local.example_app_envs
    name = "example-app-${each.key}"
    organization = local.organization_name
    project_id = tfe_project.example_app.id
    description = each.value.description
    working_directory = each.value.working_directory

    vcs_repo {
        identifier     = "mkdatz14/example-app"
        oauth_token_id = var.github_oauth_token_id
        branch         = "main"
    }

    auto_apply = each.value.auto_apply
    file_triggers_enabled = true
    trigger_prefixes = each.value.trigger_prefixes
}

resource "tfe_variable" "example_app_plan_args" {
    for_each = local.example_app_envs

    key = "TF_CLI_ARGS_plan"
    value = "-var-file=${each.key}.tfvars"
    category = "env"
    workspace_id = tfe_workspace.example_app[each.key].id
}

resource "tfe_variable" "example_app_apply_args" {
    for_each = local.example_app_envs

    key = "TF_CLI_ARGS_apply"
    value = "-var-file=${each.key}.tfvars"
    category = "env"
    workspace_id = tfe_workspace.example_app[each.key].id
}
