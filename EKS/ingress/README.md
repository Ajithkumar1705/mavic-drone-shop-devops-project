# Shared ALB Ingress

The ingress is intentionally kept outside the per-service Helm chart because it is a cluster-level routing resource.

`ingress.yaml`:

- uses the AWS Load Balancer Controller
- creates an internet-facing Application Load Balancer
- routes `/` to the `web` Kubernetes Service on port `8080`
- leaves internal microservice routing to Nginx

Apply manually:

```bash
kubectl apply -f EKS/ingress/ingress.yaml
```

Check the ALB hostname:

```bash
kubectl get ingress -n mavic-drone-shop
```

See [Architecture](../../docs/ARCHITECTURE.md).
