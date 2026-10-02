# Helm Deployment Layer

The Helm layer separates reusable deployment logic from service-specific configuration.

## Charts

### `service/`

Reusable chart for:

```text
web
cart
catalogue
user
payment
shipping
ratings
dispatch
```

### `infrastructure/`

Supporting infrastructure chart for:

```text
MongoDB
MySQL
Redis
RabbitMQ
```

## Values

Application values are under:

```text
service/values/<service>.yaml
```

They control service-specific configuration such as:

- image repository/tag
- ports
- replicas
- resource requests/limits
- probes
- environment variables
- monitoring

## Validate a chart

```bash
helm lint service \
  -f service/values/cart.yaml
```

Render without changing the cluster:

```bash
helm template cart service \
  -f service/values/cart.yaml \
  --set service.name=cart \
  --set image.repository=<registry>/rs-cart \
  --set image.tag=<git-sha>
```

See [Kubernetes Deployment](../../docs/KUBERNETES-DEPLOYMENT.md).
