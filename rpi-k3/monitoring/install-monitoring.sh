#!/usr/bin/env bash
# Installs/upgrades Prometheus + Grafana (kube-prometheus-stack) with resource
# limits trimmed for a Raspberry Pi cluster. Run inside the kube-tools container
# with KUBECONFIG pointing at the cluster:
#   docker exec kube-tools bash rpi-k3/monitoring/install-monitoring.sh
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --create-namespace --namespace monitoring \
  -f rpi-k3/monitoring/values.yaml

echo "Waiting for monitoring pods to be ready (first boot can take several minutes on a Pi)..."
kubectl -n monitoring wait --for=condition=Ready pod --all --timeout=600s

echo "Monitoring stack installed. Run open-monitoring.sh to access Grafana."
