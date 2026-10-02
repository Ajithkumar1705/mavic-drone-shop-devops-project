# CI/CD

## Pipeline objective

The delivery model separates **building an artifact** from **deploying an artifact**.

```text
Source change
    ↓
Changed-service detection
    ↓
Docker build
    ↓
Trivy scan
    ↓
Amazon ECR
    ↓
Selected image tag
    ↓
Helm deployment
    ↓
EKS rollout verification
```

## Continuous Integration

Workflow: `.github/workflows/ci.yml`

Triggered by pushes to `main`.

### Stage 1 — Detect changes

`dorny/paths-filter` checks service directories. The workflow can therefore build a subset of services rather than rebuilding every image.

### Stage 2 — Build

Each selected service is built from its own directory:

```bash
docker build -t <registry>/rs-<service>:<git-sha> ./<service>
```

### Stage 3 — Scan

Trivy scans the built image for `HIGH` and `CRITICAL` findings.

**Current implementation note:** the workflow uses `exit-code: '0'`, so the scan is currently reporting rather than acting as a hard failure gate. A production policy could change this to a blocking gate after the project's vulnerability baseline is established.

### Stage 4 — Publish

The image is pushed to the corresponding ECR repository using the Git commit SHA as the tag.

Example:

```text
rs-cart:9f4c2d...
```

---

## Continuous Deployment

Workflow: `.github/workflows/cd.yml`

CD is manually triggered with:

- `service`
- `image_tag`

The workflow:

1. authenticates to AWS
2. verifies the image exists in ECR
3. configures `kubectl`
4. runs `helm lint`
5. renders the chart with `helm template`
6. runs `helm upgrade --install` for the selected service
7. waits for `kubectl rollout status`

This prevents CD from rebuilding the application and makes the deployed artifact explicit.

---

## Authentication

The current workflow uses:

```text
GitHub Actions
     ↓
AWS access key + secret
     ↓
IAM user
     ↓
ECR / EKS permissions
```

The production target is:

```text
GitHub Actions
     ↓
OIDC
     ↓
IAM role
     ↓
short-lived credentials
```

---

## Test stage status

The current CI workflow contains a placeholder command rather than a real automated test suite:

```text
No test suite configured for <service> yet
```

The project therefore does not claim automated unit/integration test coverage in CI. Deployment validation is currently handled through image scanning, Helm validation, Kubernetes rollout checks, application smoke testing and monitoring verification.

---

## Useful files

| File | Role |
|---|---|
| `.github/workflows/ci.yml` | Build, scan and push |
| `.github/workflows/cd.yml` | Selected-service deployment |
| `EKS/helm/service/` | Reusable application chart |
| `EKS/helm/service/values/` | Service configuration |
| `scripts/deploy-all.sh` | Deployment utility |
