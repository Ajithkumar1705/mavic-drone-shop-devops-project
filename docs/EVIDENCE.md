# Evidence

The screenshots in `docs/assets/` document the final working state of the platform. They are sanitized publication copies: AWS account/resource identifiers, public endpoints, private IPs, local usernames/paths and workstation identity have been removed or redacted.

They are grouped by engineering outcome rather than by the historical order of troubleshooting.

## Application

| Outcome | Evidence |
|---|---|
| Application home | `08_application_home.png` |
| Product page | `09_product_page.png` |
| Cart | `10_cart.png` |
| Shipping | `11_shipping_checkout.png` |
| Payment review | `12_payment_review.png` |
| Order placed | `13_order_placed.png` |

## AWS platform

| Outcome | Evidence |
|---|---|
| EKS cluster | `14_eks_cluster.png` |
| EKS resources | `15_eks_cluster_resources.png` |
| EKS nodes | `16_eks_nodes.png` |
| ALB | `17_alb.png` |
| ECR repositories | `18_ecr_repositories.png` |
| ECR image/tag | `19_ecr_image_tag.png` |
| VPC | `20_vpc.png` |
| Subnets | `21_subnets.png` |
| NAT Gateway | `22_nat_gateway.png` |
| Kubernetes nodes | `23_kubectl_nodes.png` |
| Kubernetes monitoring resources | `24_kubectl_monitoring.png` |
| Terraform state | `25_terraform_state.png` |
| Ingress | `26_ingress_output.png` |

## Observability

| Outcome | Evidence |
|---|---|
| dispatch target | `00_prometheus_dispatch_target.png` |
| payment target | `01_prometheus_payment_target.png` |
| ratings target | `02_prometheus_ratings_target.png` |
| shipping target | `03_prometheus_shipping_target.png` |
| user target | `04_prometheus_user_target.png` |
| web target | `05_prometheus_web_target.png` |
| Grafana dashboard | `06_grafana_application_metrics.png` |
| Alertmanager | `07_alertmanager.png` |
| Prometheus overview | `27_prometheus_monitoring_targets.png` |

## How to interpret the evidence

The evidence is not intended to replace the source code. It provides visual confirmation that the documented layers were exercised in a working environment.

The strongest verification chain is:

```text
Terraform/AWS
    ↓
EKS + nodes
    ↓
Kubernetes workloads
    ↓
ALB / ingress
    ↓
Working application flow
    ↓
Prometheus targets
    ↓
Grafana / Alertmanager
```

Historical issue screenshots are intentionally excluded from the main evidence narrative. They are useful during engineering work, but the portfolio focuses on the completed implementation.
