# Security

## Implemented controls

### Container security

- Trivy image scanning in CI
- ECR scan-on-push
- immutable ECR tags
- per-service container build contexts
- non-root runtime configuration where supported

### AWS access

- dedicated GitHub Actions IAM identity
- EKS access entry/policy association for CI
- IRSA for the AWS Load Balancer Controller
- service-specific deployment flow

### Kubernetes

- application namespace separation
- reusable Helm templates
- service-level release boundaries
- readiness/liveness configuration where defined by service values

## Current CI credential model

The current implementation uses long-lived IAM access keys stored in GitHub repository secrets.

```text
GitHub Actions
      ↓
repository secrets
      ↓
IAM user
      ↓
AWS APIs
```

This is documented because it is the actual implementation. It should be considered a **portfolio-stage credential model**, not the preferred production pattern.

## Recommended production model

```text
GitHub Actions
      ↓
GitHub OIDC token
      ↓
AWS IAM role trust policy
      ↓
short-lived credentials
```

Benefits include eliminating long-lived AWS access keys from repository secrets and narrowing permissions to a specific workflow/repository identity.

## Repository secret scrub

See [`SECURITY-SCRUB.md`](SECURITY-SCRUB.md) for the public-repository sanitization policy, runtime secret model, and evidence redaction rules.

## Important repository hygiene

Before making this repository public, review all configuration for environment-specific secrets. In particular, sensitive Terraform variables should be supplied through secure CI/environment mechanisms rather than committed values.

## Vulnerability gate evolution

The current Trivy action reports `HIGH` and `CRITICAL` findings but uses a non-blocking exit code. A mature pipeline could introduce:

1. baseline management
2. dependency scanning
3. SBOM generation
4. signed images/attestations
5. blocking gates for agreed severity policies

## Production hardening roadmap

- GitHub OIDC
- AWS Secrets Manager / external secrets
- HTTPS and ACM
- NetworkPolicies
- least-privilege service identities
- managed databases
- backup/restore testing
- centralized audit logging
