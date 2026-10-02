# AWS Infrastructure

Terraform is the infrastructure-as-code layer for the project.

## Provisioned platform

| Layer | Terraform responsibility |
|---|---|
| Networking | VPC, public/private subnets, routing and NAT |
| Compute | Amazon EKS managed node group |
| Registry | ECR repositories and lifecycle policies |
| Kubernetes integration | EBS CSI, namespaces and platform resources |
| Ingress | AWS Load Balancer Controller + IAM/IRSA |
| CI/CD access | IAM user + EKS access entry/policy |
| Monitoring | kube-prometheus-stack + dashboard ConfigMap |
| State | S3 backend with locking bootstrap |

## Default parameters

```text
Region:             ap-south-1
VPC:                10.0.0.0/16
Availability Zones: ap-south-1a, ap-south-1b
EKS cluster:        mavic-drone-shop-eks
Kubernetes version: 1.35
Node type:          m7i-flex.large
Desired nodes:      2
Minimum nodes:      1
Maximum nodes:      3
```

These values are defined in `Terraform/variables.tf` and should be treated as portfolio defaults rather than universal production recommendations.

## Important Terraform files

| File | Purpose |
|---|---|
| `vpc.tf` | VPC/networking |
| `eks.tf` | EKS cluster and managed node group |
| `ecr.tf` | ECR repositories |
| `alb-controller.tf` | AWS Load Balancer Controller |
| `monitoring.tf` | Prometheus/Grafana/Alertmanager stack |
| `grafana-dashboards.tf` | Application dashboard configuration |
| `github-actions-user.tf` | CI IAM identity and EKS access |
| `rbac.tf` | Kubernetes permissions used by CI |
| `backend.tf` | Terraform state backend |
| `outputs.tf` | Cluster/ECR/CI outputs |
| `bootstrap/` | Remote-state prerequisites |

## Initialization

```bash
cd Terraform
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Then apply only after reviewing the plan:

```bash
terraform apply
```

## State

The repository contains a bootstrap layer for remote Terraform state. The target model is:

```text
Terraform
   ↓
S3 state
   +
state locking
```

The actual backend configuration should be reviewed before applying it to a new AWS account.

## Cost-conscious choices

The project deliberately uses a small EKS node pool and a single NAT Gateway. This keeps the portfolio deployment practical while retaining the important DevOps architecture.

For production, the platform would require a deliberate cost/availability design rather than copying these defaults unchanged.

## Teardown

```bash
terraform destroy
```

Before teardown, confirm there are no manually created AWS resources outside Terraform and check ECR repository contents/lifecycle behaviour.
