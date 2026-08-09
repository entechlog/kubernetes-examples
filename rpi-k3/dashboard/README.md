# Kubernetes Dashboard (optional)

Kubernetes Dashboard is a general-purpose, web-based UI for Kubernetes clusters. It's not required to run the cluster and isn't installed by default — [monitoring](../monitoring/) (Prometheus + Grafana) covers ongoing cluster observability with a lighter footprint. Install the dashboard only if you want an ad-hoc, point-in-time UI for browsing/editing resources.

> **Note:** As of Dashboard v7, the project only supports Helm-based installation. It's also moved to the `kubernetes-retired` GitHub org — the chart repo URL in the project's own README (`https://kubernetes.github.io/dashboard/`) is stale and 404s; use `https://kubernetes-retired.github.io/dashboard/` instead. Given the "retired" status, it's worth evaluating actively-maintained alternatives such as [Headlamp](https://headlamp.dev/) for new setups.

## Install

From the repo root, run inside the `kube-tools` container:

```bash
docker exec kube-tools bash rpi-k3/dashboard/install-dashboard.sh
```

This adds the Helm repo, installs/upgrades the chart, applies the admin/read-only RBAC (`dashboard-admin.yaml` / `dashboard-read-only.yaml`), and waits for the pods to be ready.

## Access

From your own machine (not inside a container):

```bash
bash rpi-k3/dashboard/open-dashboard.sh
```

This fetches a fresh login token, opens an SSH tunnel to the cluster, and launches your browser at `https://localhost:8443` once the tunnel is confirmed up. Accept the self-signed certificate warning, then paste in the token. Leave the terminal open for as long as you want access — Ctrl+C closes the tunnel.

Override `MASTER_HOST` or `LOCAL_PORT` as environment variables if your setup differs from the defaults (`ubuntu@192.168.0.100`, port `8443`).

## Remove

```bash
helm uninstall kubernetes-dashboard -n kubernetes-dashboard
kubectl delete clusterrolebinding admin-user read-only-binding
kubectl delete clusterrole read-only-clusterrole
kubectl delete namespace kubernetes-dashboard
```

The RBAC manifests create cluster-scoped `ClusterRole`/`ClusterRoleBinding` resources, which aren't cleaned up automatically when the namespace is deleted — delete them explicitly as shown above.
