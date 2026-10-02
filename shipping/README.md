# `shipping` service

> **Shipping calculation and confirmation.** This service is packaged independently and released through the repository's service-level CI/CD workflow.

## Service contract

| Attribute | Value |
|---|---|
| Runtime | Java / Spring Boot |
| Application / metrics port | 8080 |
| Primary responsibility | Shipping calculation and confirmation |
| Main dependencies | MySQL, cart |
| Observability | /actuator/prometheus |
| Helm values | `EKS/helm/service/values/shipping.yaml` |

## Container lifecycle

The image is built from:

```text
shipping/Dockerfile
```

CI publishes an immutable Git-SHA image:

```text
rs-shipping:<git-sha>
```

The corresponding ECR repository is:

```text
rs-shipping
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
docker compose build shipping
docker compose up -d shipping
docker compose logs -f shipping
```

## Kubernetes verification

```bash
kubectl get deployment/shipping -n mavic-drone-shop
kubectl get pods -n mavic-drone-shop -l app=shipping
kubectl rollout status deployment/shipping -n mavic-drone-shop
```

For troubleshooting:

```bash
kubectl describe deployment/shipping -n mavic-drone-shop
kubectl logs deployment/shipping -n mavic-drone-shop
```

## Deployment model

A change under `shipping/` is detected by GitHub Actions. CI builds/scans/pushes the new image. CD can then deploy only `shipping` using the image tag produced by CI.

See:

- [CI/CD](../docs/CI-CD.md)
- [Kubernetes Deployment](../docs/KUBERNETES-DEPLOYMENT.md)
- [Service Catalog](../docs/SERVICE-CATALOG.md)
