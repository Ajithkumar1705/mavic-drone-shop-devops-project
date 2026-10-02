# Kubernetes / Amazon EKS

This directory contains the Kubernetes delivery layer.

## Layout

```text
EKS/
├── helm/
│   ├── infrastructure/      # MongoDB, MySQL, Redis, RabbitMQ
│   └── service/             # reusable application chart
└── ingress/
    └── ingress.yaml          # shared AWS ALB ingress
```

## Namespaces

```text
mavic-drone-shop   → application workloads
monitoring         → Prometheus / Grafana / Alertmanager
```

## Deployment model

Application services use one reusable Helm chart. The service-specific values files provide the differences.

The supporting data/messaging tier uses a separate infrastructure chart.

## External traffic

```text
Internet
   ↓
AWS Load Balancer Controller
   ↓
Application Load Balancer
   ↓
web Service
   ↓
Nginx / backend services
```

## Common commands

```bash
kubectl get nodes
kubectl get pods -n mavic-drone-shop
kubectl get ingress -n mavic-drone-shop
```

For complete deployment instructions, see [Kubernetes Deployment](../docs/KUBERNETES-DEPLOYMENT.md).
