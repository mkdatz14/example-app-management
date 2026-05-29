provider "tfe" {
  hostname = "app.terraform.io"
}

locals {
  organization_name = "mkdatz"
}

data "tfe_organization" "this" {
  name = local.organization_name
}
