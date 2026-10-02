#!/usr/bin/env bash
# deploy-all.sh
#
# Deploys the whole Mavic Drone Shop onto the EKS cluster and checks that both
# the APPLICATION and the MONITORING are up:
#   1. preflight  - cluster reachable, monitoring stack installed, ECR images exist
#   2. data tier  - mysql, mongodb, redis, rabbitmq   (helm release "infrastructure")
#   3. services   - cart catalogue user payment shipping ratings dispatch web
#   4. ingress    - ALB in front of "web"
#   5. verify     - pod status + Prometheus targets (scripts/verify-monitoring.sh)
#
# It always deploys the NEWEST image pushed to each ECR repo (rs-<name>).
#
# Usage:  ./scripts/deploy-all.sh
# Env:    AWS_REGION (ap-south-1)  APP_NAMESPACE (mavic-drone-shop)
# Needs:  aws, kubectl, helm  (kubectl already pointed at the cluster:
#         aws eks update-kubeconfig --name mavic-drone-shop-eks --region ap-south-1)

set -uo pipefail

REGION="${AWS_REGION:-ap-south-1}"
NS="${APP_NAMESPACE:-mavic-drone-shop}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVICES=(cart catalogue user payment shipping ratings dispatch web)
IMAGES=("${SERVICES[@]}" mysql mongo)     # mysql/mongo = seed-data DB images

say()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[33mWARN: %s\033[0m\n' "$*"; }
die()  { printf '\033[31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }

for bin in aws kubectl helm; do command -v "$bin" >/dev/null || die "missing required tool: $bin"; done

# ---------------------------------------------------------------- 1. preflight
say "Preflight"
ACCOUNT="$(aws sts get-caller-identity --query Account --output text)" || die "AWS credentials not working"
REGISTRY="$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"
kubectl get nodes >/dev/null 2>&1 || die "kubectl cannot reach the cluster (run aws eks update-kubeconfig ...)"

kubectl get crd servicemonitors.monitoring.coreos.com >/dev/null 2>&1 \
  || die "Monitoring stack not installed (no ServiceMonitor CRD). Run 'terraform apply' in Terraform/ first."
kubectl -n monitoring get pods --no-headers 2>/dev/null | grep -qv -E "Running|Completed" \
  && warn "some pods in 'monitoring' are not Running yet (kubectl get pods -n monitoring)"
kubectl -n kube-system get ds ebs-csi-node >/dev/null 2>&1 \
  || warn "EBS CSI driver not found - redis volume will stay Pending (apply the eks.tf change)"

declare -A TAG
missing=()
for img in "${IMAGES[@]}"; do
  t="$(aws ecr describe-images --region "$REGION" --repository-name "rs-$img" \
        --query 'sort_by(imageDetails,&imagePushedAt)[-1].imageTags[0]' --output text 2>/dev/null || echo None)"
  if [[ -z "$t" || "$t" == "None" ]]; then missing+=("rs-$img"); else TAG[$img]="$t"; fi
done
if (( ${#missing[@]} )); then
  printf 'No image found in ECR for: %s\n' "${missing[*]}" >&2
  echo "Push a change under each folder (e.g. 'date >> mysql/.ci-trigger') so the ci workflow builds it, then re-run." >&2
  exit 1
fi
for img in "${IMAGES[@]}"; do printf '  rs-%-10s %s\n' "$img" "${TAG[$img]}"; done

# ------------------------------------------------------------- 2. data tier
say "Deploying data tier (mysql, mongodb, redis, rabbitmq)"
: "${MYSQL_PASSWORD:?Set MYSQL_PASSWORD before deploying}"
: "${RABBITMQ_USER:?Set RABBITMQ_USER before deploying}"
: "${RABBITMQ_PASSWORD:?Set RABBITMQ_PASSWORD before deploying}"
: "${APP_SECRET:?Set APP_SECRET before deploying}"
: "${SEED_USER_NAME:?Set SEED_USER_NAME before deploying}"
: "${SEED_USER_PASSWORD:?Set SEED_USER_PASSWORD before deploying}"
: "${SEED_USER_EMAIL:?Set SEED_USER_EMAIL before deploying}"
: "${SEED_STAN_NAME:?Set SEED_STAN_NAME before deploying}"
: "${SEED_STAN_PASSWORD:?Set SEED_STAN_PASSWORD before deploying}"
: "${SEED_STAN_EMAIL:?Set SEED_STAN_EMAIL before deploying}"
: "${SEED_PARTNER_NAME:?Set SEED_PARTNER_NAME before deploying}"
: "${SEED_PARTNER_PASSWORD:?Set SEED_PARTNER_PASSWORD before deploying}"
: "${SEED_PARTNER_EMAIL:?Set SEED_PARTNER_EMAIL before deploying}"

SECRET_VALUES="$(mktemp)"
trap 'rm -f "$SECRET_VALUES"' EXIT
cat > "$SECRET_VALUES" <<EOF
secrets:
  mysqlPassword: ${MYSQL_PASSWORD@Q}
  rabbitmqUser: ${RABBITMQ_USER@Q}
  rabbitmqPassword: ${RABBITMQ_PASSWORD@Q}
  appSecret: ${APP_SECRET@Q}
  seedUserName: ${SEED_USER_NAME@Q}
  seedUserPassword: ${SEED_USER_PASSWORD@Q}
  seedUserEmail: ${SEED_USER_EMAIL@Q}
  seedStanName: ${SEED_STAN_NAME@Q}
  seedStanPassword: ${SEED_STAN_PASSWORD@Q}
  seedStanEmail: ${SEED_STAN_EMAIL@Q}
  seedPartnerName: ${SEED_PARTNER_NAME@Q}
  seedPartnerPassword: ${SEED_PARTNER_PASSWORD@Q}
  seedPartnerEmail: ${SEED_PARTNER_EMAIL@Q}
EOF
chmod 600 "$SECRET_VALUES"

helm upgrade --install infrastructure "$ROOT/EKS/helm/infrastructure" \
  --namespace "$NS" --create-namespace \
  -f "$ROOT/EKS/helm/infrastructure/values-dev.yaml" \
  -f "$SECRET_VALUES" \
  --set mysql.image.repository="$REGISTRY/rs-mysql"   --set mysql.image.tag="${TAG[mysql]}" \
  --set mongodb.image.repository="$REGISTRY/rs-mongo" --set mongodb.image.tag="${TAG[mongo]}" \
  || die "helm install of infrastructure failed"

for d in mongodb rabbitmq; do
  kubectl -n "$NS" rollout status "deployment/$d" --timeout=5m || die "$d did not become ready"
done
kubectl -n "$NS" rollout status statefulset/redis --timeout=5m \
  || die "redis not ready (kubectl describe pvc -n $NS ; check EBS CSI driver)"
echo "Waiting for MySQL to finish importing seed data (can take a few minutes)..."
kubectl -n "$NS" rollout status deployment/mysql --timeout=15m \
  || die "mysql not ready (kubectl logs deploy/mysql -n $NS)"

# --------------------------------------------------------------- 3. services
say "Deploying services"
failed=()
for svc in "${SERVICES[@]}"; do
  echo "--- $svc (${TAG[$svc]})"
  helm upgrade --install "$svc" "$ROOT/EKS/helm/service" \
    --namespace "$NS" \
    -f "$ROOT/EKS/helm/service/values/$svc.yaml" \
    --set service.name="$svc" \
    --set image.repository="$REGISTRY/rs-$svc" \
    --set image.tag="${TAG[$svc]}" \
    --wait --timeout 10m || failed+=("$svc")
done

# helm --wait returns immediately for these charts (maxUnavailable: 1 on a single
# replica), so wait on each rollout explicitly. This is what really means "running".
say "Waiting for every service to be Ready"
for svc in "${SERVICES[@]}"; do
  kubectl -n "$NS" rollout status "deployment/$svc" --timeout=5m \
    || { warn "$svc not ready (kubectl logs deploy/$svc -n $NS)"; [[ " ${failed[*]} " == *" $svc "* ]] || failed+=("$svc"); }
done

# ---------------------------------------------------------------- 4. ingress
say "Applying ingress"
kubectl apply -f "$ROOT/EKS/ingress/ingress.yaml" || warn "ingress apply failed"
URL=""
for _ in $(seq 1 30); do
  URL="$(kubectl -n "$NS" get ingress mavic-drone-shop -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)"
  [[ -n "$URL" ]] && break
  sleep 10
done

# ----------------------------------------------------------------- 5. verify
say "Pods"
kubectl -n "$NS" get pods -o wide

say "Monitoring check"
"$ROOT/scripts/verify-monitoring.sh"; mon_rc=$?

say "Summary"
(( ${#failed[@]} )) && echo "Services that failed to deploy: ${failed[*]}" || echo "Application: all 8 services deployed and Ready"
[[ $mon_rc -eq 0 ]] && echo "Monitoring : all targets scraped" || echo "Monitoring : see table above"
if [[ -n "$URL" ]]; then
  echo "Shop URL   : http://$URL   (ALB can take 2-3 more minutes to start serving)"
else
  echo "Shop URL   : ALB not ready yet - check: kubectl get ingress -n $NS"
fi
echo "Grafana    : kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80  -> http://localhost:3000 (admin / your grafana_admin_password)"
echo "Traffic    : generate load so dashboard panels fill:  ./load-gen/load-gen.sh -h http://${URL:-<shop-url>} -n 2"

(( ${#failed[@]} )) && exit 1
exit $mon_rc
