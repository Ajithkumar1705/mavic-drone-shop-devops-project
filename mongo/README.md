# `mongo` service

> **MongoDB document database used by catalogue and user workflows.**

## Role

The `mongo` container is part of the shared infrastructure tier and is deployed separately from the stateless application services.

| Attribute | Value |
|---|---|
| Service type | Stateful/supporting infrastructure |
| Main consumers | catalogue, user |
| Docker build | `mongo/Dockerfile` |
| Kubernetes chart | `EKS/helm/infrastructure` |

## Local development

```bash
docker compose build mongo
docker compose up -d mongo
docker compose logs -f mongo
```

## Kubernetes

The service is defined in:

```text
EKS/helm/infrastructure/templates/mongodb.yaml
```

The infrastructure chart keeps stateful/supporting services separate from application releases.

## Operational note

This portfolio runs the supporting data tier in the Kubernetes environment for repeatability. A production design would normally evaluate managed database services, backups, encryption and a tested restore process.
