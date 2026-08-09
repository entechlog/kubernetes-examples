#!/usr/bin/env bash
# Installs/upgrades the Kubernetes Dashboard via Helm and applies the admin/read-only RBAC.
# Run inside the kube-tools container with KUBECONFIG pointing at the cluster:
#   docker exec kube-tools bash rpi-k3/dashboard/install-dashboard.sh
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

helm repo add kubernetes-dashboard https://kubernetes-retired.github.io/dashboard/
helm repo update
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --create-namespace --namespace kubernetes-dashboard

kubectl apply -f rpi-k3/dashboard/dashboard-admin.yaml
kubectl apply -f rpi-k3/dashboard/dashboard-read-only.yaml

echo "Waiting for dashboard pods to be ready..."
kubectl -n kubernetes-dashboard wait --for=condition=Ready pod --all --timeout=180s

echo "Dashboard installed. Run open-dashboard.sh to access it."
