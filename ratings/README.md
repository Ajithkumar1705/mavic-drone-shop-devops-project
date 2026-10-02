# `ratings` service

> **Product rating APIs.** This service is packaged independently and released through the repository's service-level CI/CD workflow.

## Service contract

| Attribute | Value |
|---|---|
| Runtime | PHP / Apache |
| Application / metrics port | 80 |
| Primary responsibility | Product rating APIs |
| Main dependencies | MySQL, catalogue |
| Observability | /metrics / ratings metrics |
| Helm values | `EKS/helm/service/values/ratings.yaml` |

## Container lifecycle

The image is built from:

```text
ratings/Dockerfile
```

CI publishes an immutable Git-SHA image:

```text
rs-ratings:<git-sha>
```

The corresponding ECR repository is:

```text
rs-ratings
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
docker compose build ratings
docker compose up -d ratings
docker compose logs -f ratings
```

## Kubernetes verification

```bash
kubectl get deployment/ratings -n mavic-drone-shop
kubectl get pods -n mavic-drone-shop -l app=ratings
kubectl rollout status deployment/ratings -n mavic-drone-shop
```

For troubleshooting:

```bash
kubectl describe deployment/ratings -n mavic-drone-shop
kubectl logs deployment/ratings -n mavic-drone-shop
```

## Deployment model

A change under `ratings/` is detected by GitHub Actions. CI builds/scans/pushes the new image. CD can then deploy only `ratings` using the image tag produced by CI.

See:

- [CI/CD](../docs/CI-CD.md)
- [Kubernetes Deployment](../docs/KUBERNETES-DEPLOYMENT.md)
- [Service Catalog](../docs/SERVICE-CATALOG.md)
