# Testing & Validation

## Validation philosophy

The repository uses multiple validation layers instead of treating one successful command as proof of a working platform.

```text
Code/configuration
      ↓
Terraform validation
      ↓
AWS infrastructure
      ↓
Kubernetes state
      ↓
Helm rendering / rollout
      ↓
Application smoke test
      ↓
Monitoring verification
```

## Terraform validation

```bash
cd Terraform
terraform fmt -check
terraform validate
terraform plan
```

## Kubernetes validation

```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -n mavic-drone-shop
kubectl get ingress -n mavic-drone-shop
```

For an individual service:

```bash
kubectl rollout status deployment/<service> \
  -n mavic-drone-shop
```

## Helm validation

```bash
helm lint EKS/helm/service \
  -f EKS/helm/service/values/<service>.yaml
```

Render before deployment:

```bash
helm template <service> EKS/helm/service \
  -f EKS/helm/service/values/<service>.yaml \
  --set service.name=<service> \
  --set image.repository=<repository> \
  --set image.tag=<git-sha>
```

## Application validation

The final-state evidence captures an application transaction through:

```text
Home
 → Product
 → Cart
 → Shipping
 → Payment review
 → Order placed
```

Evidence:

- [`assets/08_application_home.png`](assets/08_application_home.png)
- [`assets/09_product_page.png`](assets/09_product_page.png)
- [`assets/10_cart.png`](assets/10_cart.png)
- [`assets/11_shipping_checkout.png`](assets/11_shipping_checkout.png)
- [`assets/12_payment_review.png`](assets/12_payment_review.png)
- [`assets/13_order_placed.png`](assets/13_order_placed.png)

## Monitoring validation

```bash
./scripts/verify-monitoring.sh
```

The evidence set contains Prometheus target screenshots for multiple application services plus Grafana and Alertmanager.

## CI test status

The CI workflow currently contains a placeholder test step rather than an automated unit/integration test suite. Therefore this repository should be described as having **deployment/runtime validation**, not as having comprehensive automated application test coverage.

That is a deliberate documentation boundary: the repository claims only what is implemented.
