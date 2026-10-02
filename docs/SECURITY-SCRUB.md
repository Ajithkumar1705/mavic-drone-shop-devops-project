# Repository Security & Secret Scrub

This repository is intended to be publishable as a portfolio project. Before publishing, all real credentials and environment-specific identifiers must stay outside Git.

## Removed from source

The public repository no longer contains:

- hard-coded MySQL passwords
- hard-coded Grafana admin passwords
- hard-coded PHP application secrets
- hard-coded RabbitMQ credentials
- hard-coded MongoDB demo-user passwords or personal-looking seed email addresses
- hard-coded load-test credentials
- real external/client IP addresses used only for load generation
- AWS account IDs and resource identifiers in evidence screenshots
- ALB/ECR hostnames in evidence screenshots
- local usernames, workstation names and project filesystem paths in terminal screenshots
- private network/resource identifiers exposed by AWS console screenshots

## Runtime secret model

### Local Docker Compose

1. Copy `.env.example` to `.env`.
2. Replace every `replace-with-*` value.
3. Run Docker Compose normally.

`.env` is ignored by Git.

### EKS / Helm

The infrastructure chart creates `mavic-drone-shop-runtime` as a Kubernetes Secret. Secret values are supplied at deployment time and are not stored in `values.yaml`. Application services consume only the required keys through `secretKeyRef`.

The deployment helper creates a temporary, permission-restricted values file and removes it when the script exits.

### Terraform

`grafana_admin_password` has no committed default. Supply it through `TF_VAR_grafana_admin_password` or another secure Terraform variable mechanism.

## CI/CD credentials

GitHub Actions currently authenticates to AWS using repository secrets containing IAM access-key credentials. No access key or secret key is committed to Git. For a production implementation, replace this with GitHub OIDC and short-lived IAM role credentials.

## Screenshot policy

Evidence images are sanitized copies. AWS account IDs, resource IDs, hostnames, IP addresses, local paths and personal workstation identifiers are intentionally redacted while retaining enough context to demonstrate the implementation.

## Recommended pre-publish scan

Run a secret scanner before making the repository public. For example:

```bash
gitleaks dir .
```

Also review `git diff --cached` before every public push.
