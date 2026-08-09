# Cluster Monitoring (Prometheus + Grafana)

[kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) bundles Prometheus, Grafana, Alertmanager, node-exporter, and kube-state-metrics into one Helm chart — this is the "real use case" workload for the cluster: ongoing visibility into node and pod health over time, not just a point-in-time snapshot.

`values.yaml` trims the chart's defaults (which assume 2-4Gi for Prometheus alone) down to a footprint that fits comfortably on a 3-node Raspberry Pi 4 (8GB) cluster. It also extends Grafana's startup probes — first boot on a Pi is slow, since Grafana downloads a handful of default app plugins (Explore Logs/Traces/Profiles, etc. — unused here) over the network before it starts serving, and the default probe timing kills the pod before that finishes.

## Install

From the repo root, run inside the `kube-tools` container:

```bash
docker exec kube-tools bash rpi-k3/monitoring/install-monitoring.sh
```

First install can take several minutes (image pulls + Grafana's plugin downloads over the Pi's network). Subsequent runs are much faster since images are cached.

## Access Grafana

From your own machine (not inside a container):

```bash
bash rpi-k3/monitoring/open-monitoring.sh
```

This fetches the Grafana admin password, opens an SSH tunnel, and launches your browser at `http://localhost:3000`. Log in as `admin` with the printed password. Leave the terminal open for as long as you want access — Ctrl+C closes the tunnel.

Override `MASTER_HOST` or `LOCAL_PORT` as environment variables if your setup differs from the defaults (`ubuntu@192.168.0.100`, port `3000`).

## Known issue: `kubectl top` / metrics-server

k3s's bundled `metrics-server` doesn't come up healthy on this setup (`kubectl top nodes` returns "Metrics API not available"). This is unrelated to the monitoring stack above — Prometheus scrapes node-exporter and kube-state-metrics directly and doesn't depend on the Kubernetes metrics-server API. `kubectl top` and Horizontal Pod Autoscaling are the only things affected. Patching the deployment with `--kubelet-insecure-tls` (the standard k3s fix for kubelet's self-signed certs) didn't resolve it on first attempt; needs further investigation.

## Remove

```bash
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete namespace monitoring
```
