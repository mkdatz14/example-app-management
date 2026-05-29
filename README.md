# example-app-management

This repository manages HCP Terraform itself. It does not provision cloud infrastructure, application code, CI/CD pipelines, or example environment modules.

## What This Repository Creates

The root Terraform module manages HCP Terraform objects in organization `my-organization`:

- one project: `example-app`
- three workspaces: `example-app-dev`, `example-app-staging`, and `example-app-prod`
- VCS settings for each workspace, including repository identifier, branch, and working directory
- file-based trigger patterns for each workspace
- optional workspace variables when you provide them through input variables

## Repository Layout

```text
.
├── .gitignore
├── README.md
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
├── variables.tf
└── versions.tf
```

## Workspace Mapping

All three workspaces point at the same VCS repository, but each uses a different working directory:

| Workspace | Working Directory |
| --- | --- |
| `example-app-dev` | `envs/dev` |
| `example-app-staging` | `envs/staging` |
| `example-app-prod` | `envs/prod` |

This repository assumes those directories exist in the application Terraform repository that the workspaces will track.

## Trigger Patterns

The `tfe_workspace` resources enable file-based VCS triggers and set these patterns:

- `example-app-dev`: `envs/dev/**`, `shared/**`, `modules/**`
- `example-app-staging`: `envs/staging/**`, `shared/**`, `modules/**`
- `example-app-prod`: `envs/prod/**`, `shared/**`, `modules/**`

Because `shared/**` and `modules/**` are common paths, changes there will trigger every dependent workspace.

## Prerequisites

- Terraform CLI installed locally
- an HCP Terraform or Terraform Enterprise API token with permission to manage projects and workspaces
- an existing VCS connection or OAuth client/token ID already configured in HCP Terraform
- the target VCS repository already created

Provide authentication by setting `TFE_TOKEN` or by supplying `tfe_token` as a sensitive variable.

## Configuration

Start from `terraform.tfvars.example` and provide values for:

- `organization_name`
- `project_name`
- `vcs_repository_identifier`
- `vcs_oauth_token_id`
- `vcs_branch`
- optional `workspace_variables`

The scaffold uses an existing VCS OAuth connection ID in the workspace `vcs_repo` block. If your organization uses a GitHub App installation instead, adapt the `vcs_repo` block accordingly before applying.

## Running Terraform

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Notes On Trigger Support

The current `hashicorp/tfe` provider supports `file_triggers_enabled`, `working_directory`, and `trigger_patterns` directly on `tfe_workspace`, so this repository manages the requested trigger behavior in Terraform rather than relying on a manual post-create step.
