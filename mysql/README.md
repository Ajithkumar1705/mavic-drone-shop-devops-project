# `mysql` service

> **MySQL relational database used by shipping and ratings.**

## Role

The `mysql` container is part of the shared infrastructure tier and is deployed separately from the stateless application services.

| Attribute | Value |
|---|---|
| Service type | Stateful/supporting infrastructure |
| Main consumers | shipping, ratings |
| Docker build | `mysql/Dockerfile` |
| Kubernetes chart | `EKS/helm/infrastructure` |

## Local development

```bash
docker compose build mysql
docker compose up -d mysql
docker compose logs -f mysql
```

## Kubernetes

The service is defined in:

```text
EKS/helm/infrastructure/templates/mysql.yaml
```

The infrastructure chart keeps stateful/supporting services separate from application releases.

## Operational note

This portfolio runs the supporting data tier in the Kubernetes environment for repeatability. A production design would normally evaluate managed database services, backups, encryption and a tested restore process.
