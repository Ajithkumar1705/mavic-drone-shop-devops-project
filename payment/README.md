# `payment` service

> **Checkout/payment workflow and order event publishing.** This service is packaged independently and released through the repository's service-level CI/CD workflow.

## Service contract

| Attribute | Value |
|---|---|
| Runtime | Python |
| Application / metrics port | 8080 |
| Primary responsibility | Checkout/payment workflow and order event publishing |
| Main dependencies | cart, user, RabbitMQ |
| Observability | sold_count |
| Helm values | `EKS/helm/service/values/payment.yaml` |

## Container lifecycle

The image is built from:

```text
payment/Dockerfile
```

CI publishes an immutable Git-SHA image:

```text
rs-payment:<git-sha>
```

The corresponding ECR repository is:

```text
rs-payment
```

## Kubernetes lifecycle

The service is deployed by the reusable chart:

```text
EKS/helm/service
```

The service-specific values file controls the settings that differ from the other workloads, such as image, port, resources, probes and monitoring.

## Local development

Build and start only this service:

```bash
docker compose build payment
docker compose up -d payment
docker compose logs -f payment
```

## Kubernetes verification

```bash
kubectl get deployment/payment -n mavic-drone-shop
kubectl get pods -n mavic-drone-shop -l app=payment
kubectl rollout status deployment/payment -n mavic-drone-shop
```

For troubleshooting:

```bash
kubectl describe deployment/payment -n mavic-drone-shop
kubectl logs deployment/payment -n mavic-drone-shop
```

## Deployment model

A change under `payment/` is detected by GitHub Actions. CI builds/scans/pushes the new image. CD can then deploy only `payment` using the image tag produced by CI.

See:

- [CI/CD](../docs/CI-CD.md)
- [Kubernetes Deployment](../docs/KUBERNETES-DEPLOYMENT.md)
- [Service Catalog](../docs/SERVICE-CATALOG.md)
