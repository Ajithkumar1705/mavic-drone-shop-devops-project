# Load Generator

The `load-gen` directory contains a small traffic-generation utility used to create realistic application activity for dashboard and monitoring validation.

## Run

Against local Docker Compose:

```bash
./load-gen/load-gen.sh -h http://localhost:8080 -n 2
```

Against the deployed application:

```bash
./load-gen/load-gen.sh -h http://<alb-hostname> -n 2
```

## Why it exists

The goal is not performance benchmarking. It is to generate enough normal application traffic to demonstrate that:

```text
Application activity
      ↓
Application metrics
      ↓
Prometheus
      ↓
Grafana dashboard
```

For actual load/performance testing, use a dedicated test plan with controlled concurrency, duration, success criteria and resource monitoring.
