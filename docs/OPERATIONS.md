# Operations

## Daily health checks

```bash
kubectl get nodes
kubectl get pods -n mavic-drone-shop
kubectl get ingress -n mavic-drone-shop
kubectl get servicemonitor -A
```

## Deployment verification

```bash
kubectl rollout status deployment/<service> \
  -n mavic-drone-shop
```

## Investigate a failed pod

```bash
kubectl describe pod <pod> -n mavic-drone-shop
kubectl logs <pod> -n mavic-drone-shop
kubectl logs <pod> -n mavic-drone-shop --previous
```

## Investigate a service

```bash
kubectl get svc <service> -n mavic-drone-shop
kubectl get endpoints <service> -n mavic-drone-shop
```

## Helm release history

```bash
helm list -n mavic-drone-shop
helm history <release> -n mavic-drone-shop
```

Rollback a known-good release:

```bash
helm rollback <release> <revision> \
  -n mavic-drone-shop \
  --wait
```

## Monitoring checks

```bash
./scripts/verify-monitoring.sh
```

## ECR checks

```bash
aws ecr describe-images \
  --repository-name rs-<service> \
  --region ap-south-1
```

## Operational principle

When troubleshooting, move from the outside inward:

```text
ALB / ingress
    ↓
Kubernetes Service
    ↓
Pod / container
    ↓
Application logs
    ↓
Dependency service
    ↓
Database / queue / cache
```

This makes failures easier to isolate than restarting components without identifying the failing layer.
