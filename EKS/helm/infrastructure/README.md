# Infrastructure Helm Chart

This chart deploys the shared stateful/supporting tier used by the application.

## Components

```text
MongoDB
MySQL
Redis
RabbitMQ
```

## Why a separate chart?

These components have a different lifecycle from stateless application releases. Keeping them separate avoids coupling a routine application deployment to the data/messaging layer.

## Files

```text
templates/mongodb.yaml
 templates/mysql.yaml
 templates/redis.yaml
 templates/rabbitmq.yaml
```

## Validate

```bash
helm lint .
helm template infrastructure .
```

## Deployment

The full deployment script handles the infrastructure chart before the application releases.

See `scripts/deploy-all.sh` and [Kubernetes Deployment](../../../docs/KUBERNETES-DEPLOYMENT.md).
