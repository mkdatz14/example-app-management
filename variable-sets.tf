locals {
  # Define stable shared variables here when you want HCP Terraform to own them.
  # Keep secrets out of plain text in git unless that tradeoff is intentional.
  example_app_shared_variables = {
  }

  example_app_shared_variable_set = length(local.example_app_shared_variables) > 0 ? {
    shared = {
      name        = "example-app-shared"
      description = "Stable project-level variables shared across all example-app workspaces."
    }
  } : {}
}

resource "tfe_variable_set" "example_app_shared" {
  for_each = local.example_app_shared_variable_set

  name         = each.value.name
  description  = each.value.description
  organization = local.organization_name
}

resource "tfe_project_variable_set" "example_app_shared" {
  for_each = local.example_app_shared_variable_set

  project_id      = tfe_project.example_app.id
  variable_set_id = tfe_variable_set.example_app_shared[each.key].id
}

resource "tfe_variable" "example_app_shared" {
  for_each = local.example_app_shared_variables

  category        = try(each.value.category, "terraform")
  description     = try(each.value.description, null)
  hcl             = try(each.value.hcl, false)
  key             = each.key
  sensitive       = try(each.value.sensitive, false)
  value           = each.value.value
  variable_set_id = tfe_variable_set.example_app_shared["shared"].id
}