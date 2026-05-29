# example-app-management

This repository manages HCP Terraform itself. It does not provision cloud infrastructure, application code, CI/CD pipelines, or example environment modules.

## What This Repository Creates

The root Terraform module manages HCP Terraform objects in organization `mkdatz`:

- one management workspace: `example-app-management`
- one project: `example-app`
- three workspaces: `example-app-dev`, `example-app-staging`, and `example-app-prod`
- VCS settings for each workspace, including repository identifier, branch, and working directory
- file-based trigger patterns for the application workspaces
- workspace environment variables that set `TF_CLI_ARGS_plan` and `TF_CLI_ARGS_apply` for each application workspace

## Repository Layout

```text
.
├── README.md
├── main.tf
├── outputs.tf
├── projects.tf
├── terraform.tfvars.example
├── variables.tf
├── versions.tf
└── workspaces.tf
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

The `tfe_workspace.example_app` resources enable file-based VCS triggers and set these patterns:

- `example-app-dev`: `envs/dev/**`, `shared/**`
- `example-app-staging`: `envs/staging/**`, `shared/**`
- `example-app-prod`: `envs/prod/**`, `shared/**`

Because `shared/**` is a common path, changes there will trigger every dependent workspace.

## Prerequisites

- Terraform CLI installed locally
- an HCP Terraform or Terraform Enterprise API token with permission to manage projects and workspaces
- a manually created HCP Terraform workspace named `example-app-management`
- an existing GitHub VCS connection in HCP Terraform, with a valid OAuth token ID
- the target repositories already created: `mkdatz14/example-app-management` and `mkdatz14/example-app`

Provide authentication by setting `TFE_TOKEN`.

## Bootstrap Flow

The management workspace must exist before this configuration can fully manage itself.

1. Create the HCP Terraform workspace `example-app-management` manually in organization `mkdatz`.
2. Create a local `terraform.tfvars` from `terraform.tfvars.example` and set `github_oauth_token_id` to the HCP Terraform VCS OAuth token ID for your GitHub connection.
3. Initialize Terraform:

```bash
terraform init
```

4. Import the manually created workspace into state before planning or applying:

```bash
terraform import tfe_workspace.example_app_management mkdatz/example-app-management
```

5. Review the plan:

```bash
terraform plan -var-file=terraform.tfvars
```

6. Apply the remaining HCP Terraform objects:

```bash
terraform apply -var-file=terraform.tfvars
```

## Configuration

Create `terraform.tfvars` from `terraform.tfvars.example` and provide:

- `github_oauth_token_id`

This repository currently uses the same `github_oauth_token_id` in the `vcs_repo` block for the management workspace and all application workspaces.

## Running Terraform

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Notes On Trigger Support

The current configuration uses `file_triggers_enabled`, `working_directory`, and `trigger_prefixes` directly on `tfe_workspace`.
