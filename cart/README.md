# `cart` service

> **Shopping cart and cart session handling.** This service is packaged independently and released through the repository's service-level CI/CD workflow.

## Service contract

| Attribute | Value |
|---|---|
| Runtime | Node.js |
| Application / metrics port | 8080 |
| Primary responsibility | Shopping cart and cart session handling |
| Main dependencies | Redis, catalogue |
| Observability | items_added |
| Helm values | `EKS/helm/service/values/cart.yaml` |

## Container lifecycle

The image is built from:

```text
cart/Dockerfile
```

CI publishes an immutable Git-SHA image:

```text
rs-cart:<git-sha>
```

The corresponding ECR repository is:

```text
rs-cart
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
docker compose build cart
docker compose up -d cart
docker compose logs -f cart
```

## Kubernetes verification

```bash
kubectl get deployment/cart -n mavic-drone-shop
kubectl get pods -n mavic-drone-shop -l app=cart
kubectl rollout status deployment/cart -n mavic-drone-shop
```

For troubleshooting:

```bash
kubectl describe deployment/cart -n mavic-drone-shop
kubectl logs deployment/cart -n mavic-drone-shop
```

## Deployment model

A change under `cart/` is detected by GitHub Actions. CI builds/scans/pushes the new image. CD can then deploy only `cart` using the image tag produced by CI.

See:

- [CI/CD](../docs/CI-CD.md)
- [Kubernetes Deployment](../docs/KUBERNETES-DEPLOYMENT.md)
- [Service Catalog](../docs/SERVICE-CATALOG.md)
