# `web` service

> **Frontend and reverse proxy.** This service is packaged independently and released through the repository's service-level CI/CD workflow.

## Service contract

| Attribute | Value |
|---|---|
| Runtime | Nginx + AngularJS |
| Application / metrics port | 8080 |
| Primary responsibility | Frontend and reverse proxy |
| Main dependencies | cart, catalogue, user, shipping, payment, ratings |
| Observability | Nginx Prometheus exporter |
| Helm values | `EKS/helm/service/values/web.yaml` |

## Container lifecycle

The image is built from:

```text
web/Dockerfile
```

CI publishes an immutable Git-SHA image:

```text
rs-web:<git-sha>
```

The corresponding ECR repository is:

```text
rs-web
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
docker compose build web
docker compose up -d web
docker compose logs -f web
```

## Kubernetes verification

```bash
kubectl get deployment/web -n mavic-drone-shop
kubectl get pods -n mavic-drone-shop -l app=web
kubectl rollout status deployment/web -n mavic-drone-shop
```

For troubleshooting:

```bash
kubectl describe deployment/web -n mavic-drone-shop
kubectl logs deployment/web -n mavic-drone-shop
```

## Deployment model

A change under `web/` is detected by GitHub Actions. CI builds/scans/pushes the new image. CD can then deploy only `web` using the image tag produced by CI.

See:

- [CI/CD](../docs/CI-CD.md)
- [Kubernetes Deployment](../docs/KUBERNETES-DEPLOYMENT.md)
- [Service Catalog](../docs/SERVICE-CATALOG.md)
