# Terraform Platform

Terraform is the infrastructure-as-code layer for the Mavic Drone Shop platform.

## What it provisions

```text
VPC / networking
     ↓
Amazon EKS + managed nodes
     ↓
ECR repositories
     ↓
IAM / EKS access
     ↓
AWS Load Balancer Controller
     ↓
Prometheus / Grafana / Alertmanager
```

## Main files

| File | Responsibility |
|---|---|
| `vpc.tf` | VPC, public/private subnets and NAT configuration |
| `eks.tf` | EKS cluster, managed node group, EBS CSI and IRSA |
| `ecr.tf` | ECR repositories, immutable tags and lifecycle |
| `alb-controller.tf` | AWS Load Balancer Controller + IAM role |
| `monitoring.tf` | kube-prometheus-stack |
| `github-actions-user.tf` | GitHub Actions IAM identity |
| `backend.tf` | Remote state configuration |
| `variables.tf` | Environment parameters |
| `outputs.tf` | Useful Terraform outputs |
| `bootstrap/` | Remote-state bucket/lock-table bootstrap |
| `dashboards/` | Grafana dashboard JSON |

## State

The backend uses S3 for state and DynamoDB for locking. The bootstrap layer creates those resources before the main platform is initialized.

## Validate and apply

```bash
terraform init -backend-config=backend.hcl
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

## Destroy

```bash
terraform destroy
```

Check ECR contents and any manually created resources before teardown.

## Important portfolio note

The current GitHub Actions identity uses IAM access keys stored in GitHub repository secrets. The production target is GitHub OIDC + short-lived IAM role credentials.


### Backend configuration

The repository does not commit the actual Terraform state bucket or lock-table names. Copy `backend.hcl.example` to `backend.hcl`, replace the placeholders, and initialize with:

```bash
terraform init -backend-config=backend.hcl
```

`backend.hcl` is ignored by Git.
