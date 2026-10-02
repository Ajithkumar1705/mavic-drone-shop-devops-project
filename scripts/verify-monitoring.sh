#!/usr/bin/env bash
# verify-monitoring.sh
#
# Checks that every Mavic Drone Shop microservice is wired into Prometheus:
#   1. a ServiceMonitor exists in the app namespace
#   2. Prometheus has an ACTIVE target for it and that target is UP
#      (it WAITS for this: right after a deploy, targets are "unknown" until the
#       first scrape, which can take 1-2 minutes)
#   3. the custom app metric used by the Grafana dashboard exists
#
# Usage:   ./scripts/verify-monitoring.sh
# Env:     APP_NAMESPACE (mavic-drone-shop)   MON_NAMESPACE (monitoring)
#          PROM_SERVICE  (monitoring-kube-prometheus-prometheus)
#          LOCAL_PORT    (9090)               WAIT_SECONDS  (180)
# Needs:   kubectl (pointed at the cluster), curl, python3

set -uo pipefail

APP_NS="${APP_NAMESPACE:-mavic-drone-shop}"
MON_NS="${MON_NAMESPACE:-monitoring}"
PROM_SVC="${PROM_SERVICE:-monitoring-kube-prometheus-prometheus}"
LOCAL_PORT="${LOCAL_PORT:-9090}"
WAIT="${WAIT_SECONDS:-180}"

declare -A CUSTOM_METRIC=(
  [cart]="items_added"
  [catalogue]="product_views"
  [user]="user_logins"
  [payment]="sold_count"
  [shipping]="http_server_requests_seconds_count"
  [ratings]="ratings_submitted"
  [dispatch]="orders_processed"
  [web]="nginx_http_requests_total"
)
SERVICES=(cart catalogue user payment shipping ratings dispatch web)

for bin in kubectl curl python3; do
  command -v "$bin" >/dev/null || { echo "missing required tool: $bin" >&2; exit 2; }
done

echo "==> Port-forwarding Prometheus ($MON_NS/svc/$PROM_SVC -> localhost:$LOCAL_PORT)"
kubectl -n "$MON_NS" port-forward "svc/$PROM_SVC" "$LOCAL_PORT:9090" >/dev/null 2>&1 &
PF_PID=$!
trap 'kill $PF_PID 2>/dev/null' EXIT

for _ in $(seq 1 20); do
  curl -fs "http://localhost:$LOCAL_PORT/-/ready" >/dev/null 2>&1 && break
  sleep 1
done
curl -fs "http://localhost:$LOCAL_PORT/-/ready" >/dev/null 2>&1 \
  || { echo "Prometheus not reachable - is the monitoring stack installed?" >&2; exit 2; }

fetch_targets() {
  TARGETS_JSON="$(curl -fs "http://localhost:$LOCAL_PORT/api/v1/targets?state=active" 2>/dev/null)" \
    || TARGETS_JSON='{"data":{"activeTargets":[]}}'
}

# prints: up | down | unknown | missing     ("unknown" = not scraped yet)
target_health() {
  printf '%s' "$TARGETS_JSON" | python3 -c '
import json, sys
svc, ns = sys.argv[1], sys.argv[2]
data = json.load(sys.stdin)
hits = [t for t in data["data"]["activeTargets"]
        if t["labels"].get("service") == svc and t["labels"].get("namespace") == ns]
if not hits: print("missing")
elif all(t["health"] == "up" for t in hits): print("up")
elif any(t["health"] == "down" for t in hits): print("down")
else: print("unknown")
' "$1" "$APP_NS"
}

# prints the scrape error of the first non-up target (empty if none)
target_error() {
  printf '%s' "$TARGETS_JSON" | python3 -c '
import json, sys
svc, ns = sys.argv[1], sys.argv[2]
data = json.load(sys.stdin)
for t in data["data"]["activeTargets"]:
    if t["labels"].get("service") == svc and t["labels"].get("namespace") == ns and t["health"] != "up":
        print((t.get("lastError") or "")[:90]); break
' "$1" "$APP_NS"
}

metric_present() {
  curl -fsG "http://localhost:$LOCAL_PORT/api/v1/query" --data-urlencode "query=count($1)" 2>/dev/null \
    | python3 -c 'import json,sys; sys.exit(0 if json.load(sys.stdin)["data"]["result"] else 1)' 2>/dev/null
}

# ---- wait until every target is up (or we run out of time)
echo "==> Waiting up to ${WAIT}s for Prometheus to scrape all targets"
deadline=$((SECONDS + WAIT))
while :; do
  fetch_targets
  pending=()
  for svc in "${SERVICES[@]}"; do
    [[ "$(target_health "$svc")" == "up" ]] || pending+=("$svc")
  done
  (( ${#pending[@]} == 0 )) && break
  (( SECONDS >= deadline )) && break
  echo "    not up yet: ${pending[*]}"
  sleep 10
done

# ---- report
fail=0
printf "\n%-11s %-15s %-9s %-34s %s\n" SERVICE SERVICEMONITOR TARGET "CUSTOM METRIC" "SCRAPE ERROR"
printf "%-11s %-15s %-9s %-34s %s\n"   ------- -------------- ------ ------------- ------------
for svc in "${SERVICES[@]}"; do
  if kubectl -n "$APP_NS" get servicemonitor "$svc" >/dev/null 2>&1; then sm="ok"; else sm="MISSING"; fail=1; fi

  health="$(target_health "$svc")"
  [[ "$health" == "up" ]] || fail=1
  err=""; [[ "$health" == "up" ]] || err="$(target_error "$svc")"

  m="${CUSTOM_METRIC[$svc]}"
  if metric_present "$m"; then mres="ok ($m)"; else mres="none yet ($m)"; fi

  printf "%-11s %-15s %-9s %-34s %s\n" "$svc" "$sm" "$health" "$mres" "$err"
done

echo
if [[ $fail -eq 0 ]]; then
  echo "All services are being scraped."
else
  echo "Some services are not being scraped. Debug with:"
  echo "  kubectl -n $APP_NS get pods,servicemonitor,svc,endpoints"
  echo "  kubectl -n $APP_NS get svc <name> -o yaml    # port NAME must match the ServiceMonitor"
  echo "  open http://localhost:$LOCAL_PORT/targets    # while the port-forward is running"
fi
echo "Note: 'none yet' for a custom metric is normal until that code path has served traffic"
echo "      (run load-gen/load-gen.sh), since counters only appear after first use."
exit $fail
