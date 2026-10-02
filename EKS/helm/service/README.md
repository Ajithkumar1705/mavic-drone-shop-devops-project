# Reusable Application Helm Chart

This chart is the deployment template for the stateless application services.

## Supported services

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

## Design

Instead of maintaining eight copies of Deployment/Service/ServiceMonitor templates, the chart contains reusable templates and service-specific values.

```text
service/
├── Chart.yaml
├── values.yaml
├── values/
│   ├── web.yaml
│   ├── cart.yaml
│   ├── catalogue.yaml
│   ├── user.yaml
│   ├── payment.yaml
│   ├── shipping.yaml
│   ├── ratings.yaml
│   └── dispatch.yaml
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── servicemonitor.yaml
    └── _helpers.tpl
```

## Validate

```bash
helm lint . -f values/cart.yaml
```

## Render

```bash
helm template cart . \
  -f values/cart.yaml \
  --set service.name=cart \
  --set image.repository=<registry>/rs-cart \
  --set image.tag=<git-sha>
```

## Monitoring

Where enabled, `servicemonitor.yaml` creates a Prometheus ServiceMonitor for the service.

## Deployment

The GitHub Actions CD workflow uses this chart to deploy only the selected service.
