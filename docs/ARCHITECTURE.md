# Architecture

![Mavic Drone Shop actual AWS EKS architecture](assets/architecture.png)

> **Accuracy rule:** the diagram and evidence panels use only components supported by the repository configuration and the supplied project screenshots. The screenshots are real project evidence; they are not generated dashboard or application mockups. Sensitive identifiers are redacted for public GitHub.

## 1. Delivery pipeline

The implemented CI/CD path is:

```text
GitHub push
   │
   ▼
GitHub Actions CI
   ├── detect changed service directories
   ├── Docker build
   ├── Trivy scan
   └── push Git-SHA image
             │
             ▼
        Amazon ECR
             │
             ▼
GitHub Actions CD (manual service + image tag)
             ├── verify ECR image
             ├── helm lint
             ├── render manifest
             ├── helm upgrade --install
             └── rollout status
             │
             ▼
          Amazon EKS
```

CI and CD are separate workflows. The CD workflow deploys only the selected service rather than rebuilding or redeploying the whole application.

## 2. AWS infrastructure

Terraform manages the platform components represented in the repository:

```text
                         Terraform
              ┌────────────┼─────────────┐
              ▼            ▼             ▼
             VPC          EKS            ECR
              │            │              │
      public/private   managed nodes   service images
        subnets       + EBS CSI
              │            │
              │      ┌─────┴─────────────┐
              │      │ application +     │
              │      │ monitoring pods   │
              │      └───────────────────┘
              │
              └── Internet-facing ALB via AWS Load Balancer Controller
                  (IRSA-backed controller)
```

The EKS cluster uses private subnets for worker nodes and public subnets for the load-balancer/NAT path. The VPC configuration intentionally uses a single NAT Gateway as a portfolio cost trade-off.

There is **no Route 53 resource represented in this repository**. The supplied evidence shows access through the ALB endpoint.

## 3. Kubernetes runtime

The application chart under `EKS/helm/service` is reused for:

- `web`
- `cart`
- `catalogue`
- `user`
- `payment`
- `shipping`
- `ratings`
- `dispatch`

The infrastructure chart under `EKS/helm/infrastructure` deploys:

- MongoDB
- MySQL
- Redis
- RabbitMQ

The shared ALB ingress is kept outside the per-service chart and is reconciled by the AWS Load Balancer Controller.

## 4. Observability

Terraform installs `kube-prometheus-stack`. The application chart can create `ServiceMonitor` resources for the services that expose metrics.

```text
Application / exporter
        │
        ▼
   ServiceMonitor
        │
        ▼
    Prometheus
      ┌─┴──────┐
      ▼        ▼
   Grafana  Alertmanager
```

The supplied evidence includes the real Grafana application metrics dashboard, real Prometheus target health, and the real Alertmanager page.

## 5. Actual evidence used in the architecture image

| Panel | Evidence |
|---|---|
| Application | `assets/13_order_placed.png` |
| EKS | `assets/14_eks_cluster.png` |
| ECR | `assets/18_ecr_repositories.png` |
| Grafana | `assets/06_grafana_application_metrics.png` |
| Prometheus | `assets/27_prometheus_monitoring_targets.png` |
| Alertmanager | `assets/07_alertmanager.png` |

All six are derived from the supplied screenshots and sanitized before publication.

## 6. Production evolution

This repository is a portfolio-sized implementation. Production hardening would normally include:

- GitHub OIDC with short-lived credentials instead of IAM access keys
- managed database services where appropriate
- multi-AZ NAT/high-availability design
- external secret management
- HTTPS with ACM
- stronger automated test gates
- centralized logging and retention
- environment promotion controls
- Kubernetes NetworkPolicies
