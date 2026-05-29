terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "mkdatz"

    workspaces {
      name = "example-app-management"
    }
  }

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.77.0"
    }
  }
}
