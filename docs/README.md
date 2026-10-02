# Engineering Documentation

This directory contains the technical documentation for the Mavic Drone Shop DevOps platform.

The root [`README.md`](../README.md) is the portfolio entry point. These documents provide the deeper engineering detail behind it.

## Recommended reading order

1. [Architecture](ARCHITECTURE.md)
2. [AWS Infrastructure](AWS-INFRASTRUCTURE.md)
3. [CI/CD](CI-CD.md)
4. [Kubernetes Deployment](KUBERNETES-DEPLOYMENT.md)
5. [Observability](OBSERVABILITY.md)
6. [Security](SECURITY.md)
7. [Testing & Validation](TESTING-VALIDATION.md)
8. [Evidence](EVIDENCE.md)
9. [Operations](OPERATIONS.md)
10. [Service Catalog](SERVICE-CATALOG.md)
11. [Local Development](LOCAL-DEVELOPMENT.md)
12. [Project Structure](PROJECT-STRUCTURE.md)

## Documentation principle

The documentation describes the repository **as implemented**. Where a production improvement is recommended but not implemented, it is explicitly labelled as a future hardening step.

## Visual evidence

The `assets/` directory contains final-state screenshots covering:

- application flow
- VPC and subnet configuration
- EKS cluster and nodes
- ECR repositories and image tags
- ALB and ingress
- Prometheus targets
- Grafana application metrics
- Alertmanager
- Terraform state
