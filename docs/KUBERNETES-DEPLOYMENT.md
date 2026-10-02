# Kubernetes Deployment

## Cluster model

The application runs in the Kubernetes namespace:

```text
mavic-drone-shop
```

The repository separates stateless application workloads from supporting infrastructure.

## Helm charts

### Application chart

```text
EKS/helm/service/
├── Chart.yaml
├── values.yaml
├── values/
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── servicemonitor.yaml
    └── _helpers.tpl
```

Supported application releases:

```text
web cart catalogue user payment shipping ratings dispatch
```

### Infrastructure chart

```text
EKS/helm/infrastructure/
```

Contains:

```text
MongoDB
MySQL
Redis
RabbitMQ
```

## Validate a release

```bash
helm lint EKS/helm/service \
  -f EKS/helm/service/values/cart.yaml
```

Render before applying:

```bash
helm template cart EKS/helm/service \
  -f EKS/helm/service/values/cart.yaml \
  --set service.name=cart \
  --set image.repository=<registry>/rs-cart \
  --set image.tag=<git-sha>
```

## Deploy a selected service

```bash
helm upgrade --install cart EKS/helm/service \
  --namespace mavic-drone-shop \
  --create-namespace \
  -f EKS/helm/service/values/cart.yaml \
  --set service.name=cart \
  --set image.repository=<registry>/rs-cart \
  --set image.tag=<git-sha> \
  --wait
```

The CD workflow performs the equivalent operation automatically for the selected service.

## Verify

```bash
kubectl get nodes
kubectl get pods -n mavic-drone-shop
kubectl get svc -n mavic-drone-shop
kubectl get ingress -n mavic-drone-shop
kubectl rollout status deployment/cart -n mavic-drone-shop
```

## Ingress

The Kubernetes ingress is defined in `EKS/ingress/ingress.yaml`. The AWS Load Balancer Controller provisions/configures the Application Load Balancer.

Evidence:

- [`assets/17_alb.png`](assets/17_alb.png)
- [`assets/26_ingress_output.png`](assets/26_ingress_output.png)

## Rollback

Helm keeps release history. For a failed application release, inspect:

```bash
helm history cart -n mavic-drone-shop
```

Then use a known-good revision:

```bash
helm rollback cart <REVISION> -n mavic-drone-shop --wait
```
