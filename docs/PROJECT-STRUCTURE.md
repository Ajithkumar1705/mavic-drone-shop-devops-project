# Project Structure

```text
.github/workflows/
├── ci.yml                    # build → scan → ECR
└── cd.yml                    # selected-service Helm deployment

web/                          # frontend / Nginx
cart/                         # cart microservice
catalogue/                    # catalogue microservice
user/                         # user microservice
payment/                      # payment microservice
shipping/                     # shipping microservice
ratings/                      # ratings microservice
dispatch/                     # dispatch microservice
mongo/                        # MongoDB image/configuration
mysql/                        # MySQL image/configuration

EKS/
├── helm/
│   ├── service/              # reusable stateless-service chart
│   └── infrastructure/       # supporting services chart
└── ingress/                  # ALB ingress definition

Terraform/
├── bootstrap/                # remote-state prerequisites
├── vpc.tf                    # networking
├── eks.tf                    # EKS
├── ecr.tf                    # registries
├── alb-controller.tf         # AWS Load Balancer Controller
├── monitoring.tf             # monitoring stack
├── grafana-dashboards.tf     # dashboard config
├── github-actions-user.tf    # CI identity
├── rbac.tf                   # Kubernetes permissions
└── outputs.tf                # useful outputs

load-gen/                     # traffic generation
scripts/                      # deployment/monitoring utilities
docs/                         # engineering docs + evidence
docker-compose.yaml           # local environment
```

## Where to look first

- CI/CD implementation → `.github/workflows/`
- AWS platform → `Terraform/`
- Kubernetes deployment → `EKS/helm/`
- External access → `EKS/ingress/`
- Monitoring → `Terraform/monitoring.tf` + Helm `ServiceMonitor`
- Application behaviour → individual service directories
- Validation → `scripts/`
