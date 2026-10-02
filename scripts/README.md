# Operational Scripts

## `deploy-all.sh`

Deploys the application platform in a repeatable sequence.

Use:

```bash
./scripts/deploy-all.sh
```

Review the script before execution when adapting the environment to a different AWS account, region or cluster name.

## `verify-monitoring.sh`

Validates the monitoring path:

```bash
./scripts/verify-monitoring.sh
```

It is intended to prove that monitoring is actually wired to the application rather than only checking whether Prometheus/Grafana pods exist.
