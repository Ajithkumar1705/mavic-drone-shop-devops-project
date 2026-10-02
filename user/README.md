# `user` service

> **User accounts, authentication and order history.** This service is packaged independently and released through the repository's service-level CI/CD workflow.

## Service contract

| Attribute | Value |
|---|---|
| Runtime | Node.js |
| Application / metrics port | 8080 |
| Primary responsibility | User accounts, authentication and order history |
| Main dependencies | MongoDB, Redis |
| Observability | user_logins |
| Helm values | `EKS/helm/service/values/user.yaml` |

## Container lifecycle

The image is built from:

```text
user/Dockerfile
```

CI publishes an immutable Git-SHA image:

```text
rs-user:<git-sha>
```

The corresponding ECR repository is:

```text
rs-user
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
docker compose build user
docker compose up -d user
docker compose logs -f user
```

## Kubernetes verification

```bash
kubectl get deployment/user -n mavic-drone-shop
kubectl get pods -n mavic-drone-shop -l app=user
kubectl rollout status deployment/user -n mavic-drone-shop
```

For troubleshooting:

```bash
kubectl describe deployment/user -n mavic-drone-shop
kubectl logs deployment/user -n mavic-drone-shop
```

## Deployment model

A change under `user/` is detected by GitHub Actions. CI builds/scans/pushes the new image. CD can then deploy only `user` using the image tag produced by CI.

See:

- [CI/CD](../docs/CI-CD.md)
- [Kubernetes Deployment](../docs/KUBERNETES-DEPLOYMENT.md)
- [Service Catalog](../docs/SERVICE-CATALOG.md)
