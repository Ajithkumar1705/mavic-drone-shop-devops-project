# `dispatch` service

> **Background order-dispatch worker.** This service is packaged independently and released through the repository's service-level CI/CD workflow.

## Service contract

| Attribute | Value |
|---|---|
| Runtime | Go |
| Application / metrics port | 2112 metrics |
| Primary responsibility | Background order-dispatch worker |
| Main dependencies | RabbitMQ |
| Observability | /metrics / orders_processed |
| Helm values | `EKS/helm/service/values/dispatch.yaml` |

## Container lifecycle

The image is built from:

```text
dispatch/Dockerfile
```

CI publishes an immutable Git-SHA image:

```text
rs-dispatch:<git-sha>
```

The corresponding ECR repository is:

```text
rs-dispatch
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
docker compose build dispatch
docker compose up -d dispatch
docker compose logs -f dispatch
```

## Kubernetes verification

```bash
kubectl get deployment/dispatch -n mavic-drone-shop
kubectl get pods -n mavic-drone-shop -l app=dispatch
kubectl rollout status deployment/dispatch -n mavic-drone-shop
```

For troubleshooting:

```bash
kubectl describe deployment/dispatch -n mavic-drone-shop
kubectl logs deployment/dispatch -n mavic-drone-shop
```

## Deployment model

A change under `dispatch/` is detected by GitHub Actions. CI builds/scans/pushes the new image. CD can then deploy only `dispatch` using the image tag produced by CI.

See:

- [CI/CD](../docs/CI-CD.md)
- [Kubernetes Deployment](../docs/KUBERNETES-DEPLOYMENT.md)
- [Service Catalog](../docs/SERVICE-CATALOG.md)
