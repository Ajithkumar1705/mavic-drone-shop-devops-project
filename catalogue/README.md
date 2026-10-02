# `catalogue` service

> **Product listing and product search.** This service is packaged independently and released through the repository's service-level CI/CD workflow.

## Service contract

| Attribute | Value |
|---|---|
| Runtime | Node.js |
| Application / metrics port | 8080 |
| Primary responsibility | Product listing and product search |
| Main dependencies | MongoDB |
| Observability | product_views |
| Helm values | `EKS/helm/service/values/catalogue.yaml` |

## Container lifecycle

The image is built from:

```text
catalogue/Dockerfile
```

CI publishes an immutable Git-SHA image:

```text
rs-catalogue:<git-sha>
```

The corresponding ECR repository is:

```text
rs-catalogue
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
docker compose build catalogue
docker compose up -d catalogue
docker compose logs -f catalogue
```

## Kubernetes verification

```bash
kubectl get deployment/catalogue -n mavic-drone-shop
kubectl get pods -n mavic-drone-shop -l app=catalogue
kubectl rollout status deployment/catalogue -n mavic-drone-shop
```

For troubleshooting:

```bash
kubectl describe deployment/catalogue -n mavic-drone-shop
kubectl logs deployment/catalogue -n mavic-drone-shop
```

## Deployment model

A change under `catalogue/` is detected by GitHub Actions. CI builds/scans/pushes the new image. CD can then deploy only `catalogue` using the image tag produced by CI.

See:

- [CI/CD](../docs/CI-CD.md)
- [Kubernetes Deployment](../docs/KUBERNETES-DEPLOYMENT.md)
- [Service Catalog](../docs/SERVICE-CATALOG.md)
