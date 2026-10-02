# Local Development

## Prerequisites

Install:

- Docker Engine / Docker Desktop
- Docker Compose
- Git

For AWS/Kubernetes work also install:

- AWS CLI
- Terraform
- kubectl
- Helm

## Runtime secrets

The repository intentionally contains no usable local credentials. Before starting the stack:

```bash
cp .env.example .env
# edit .env and replace every replace-with-* value

docker compose config >/dev/null
docker compose up -d
```

The `.env` file is ignored by Git. Do not paste production credentials into the repository or screenshots.

## Start the complete local environment

From the repository root:

```bash
docker compose up -d
```

Check services:

```bash
docker compose ps
```

Follow logs:

```bash
docker compose logs -f
```

## Rebuild a single service

Example:

```bash
docker compose build shipping
docker compose up -d shipping
docker compose logs -f shipping
```

This is useful when developing or troubleshooting one microservice without rebuilding the complete application.

## Stop the environment

```bash
docker compose down
```

To remove local volumes as well:

```bash
docker compose down -v
```

## Local-to-cloud relationship

The local environment is not a separate architecture. It provides the same service boundaries used by the cloud deployment:

```text
Docker Compose
     ↓
service Dockerfiles
     ↓
Amazon ECR
     ↓
Helm
     ↓
Amazon EKS
```

## Troubleshooting approach

Start with:

```bash
docker compose ps
docker compose logs <service>
```

Then test service-to-service connectivity from the relevant container before changing application code.
