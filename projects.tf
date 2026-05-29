resource "tfe_project" "example_app" {
  name = "example-app"
  organization = local.organization_name
}
