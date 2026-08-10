# Raspberry Pi k3s Cluster - Quick Start

Companion automation for [How to set up Kubernetes cluster with Raspberry Pi](https://www.entechlog.com/blog/general/how-to-set-up-kubernetes-cluster-with-raspberry-pi/). The blog post has the full narrative (hardware, OS flashing, networking gotchas); this README is the condensed command reference once your Pis are on the network with SSH access.

All commands below assume you're inside the `kube-tools` container (`docker exec -it kube-tools /bin/bash`) with `kubernetes-examples/` and a clone of [k3s-ansible](https://github.com/k3s-io/k3s-ansible) available, unless noted otherwise.

## 1. Configure the Pis (`rpi-k3/configure/`)

Edit `hosts.ini` with your Pis' IPs first, then run in order:

| Playbook | Purpose |
|---|---|
| `01-generate-rsa.yml` | Generate an SSH key for passwordless access |
| `02-copy-rsa.yml -i hosts.ini --ask-pass` | Copy that key to all Pis |
| `03-change-hostname.yml -e 'reboot=True' -i hosts.ini` | Set each Pi's hostname |
| `06-fix-cgroup-v2.yml -i hosts.ini` | Enable cgroup v2 (required by k3s on Kubernetes v1.35+), reboots if changed |
| `99-install-python.yml -i hosts.ini` | Only if you hit a "python3 not found" error |

Two more, useful anytime (not just first-time setup):

| Playbook | Purpose |
|---|---|
| `04-update-os.yml -i hosts.ini` | `apt update && apt upgrade` across all Pis |
| `05-health-check.yml -i hosts.ini` | Uptime, disk, memory, temperature, failed services |

## 2. Install k3s

Done via the external [k3s-ansible](https://github.com/k3s-io/k3s-ansible) collection, not this repo - see the blog's [Install k3s](https://www.entechlog.com/blog/general/how-to-set-up-kubernetes-cluster-with-raspberry-pi/#install-k3s) section for the full `inventory.yml` setup (server/agent groups, join token, `ansible-galaxy collection install`).

**After the cluster comes up**, run this once - k3s-agent nodes can come up with an incomplete pod network mesh (each agent only learns the server's route, not the other agents'), which silently breaks cross-node pod traffic (e.g. Grafana on one node failing to reach Prometheus on another) without failing the install itself:

```bash
ansible-playbook rpi-k3/configure/07-verify-cluster-network.yml -i rpi-k3/configure/hosts.ini
```

It restarts `k3s-agent` on each node to force Flannel to redo peer discovery, then asserts every node has a route to every other node's pod CIDR - it fails loudly if the mesh is still incomplete rather than reporting false success.

## 3. Monitor the cluster (`rpi-k3/monitoring/`)

```bash
docker exec kube-tools bash rpi-k3/monitoring/install-monitoring.sh   # from your host, not inside the container
bash rpi-k3/monitoring/open-monitoring.sh                             # from your own machine, opens Grafana in your browser
```

See [`monitoring/README.md`](monitoring/README.md) for resource sizing details and a known unrelated `kubectl top`/metrics-server issue.

## 4. Optional: Kubernetes Dashboard (`rpi-k3/dashboard/`)

Not installed by default - see [`dashboard/README.md`](dashboard/README.md).

## Resetting

- **Workloads only**: `helm uninstall kube-prometheus-stack -n monitoring && kubectl delete namespace monitoring` (see the dashboard README for its own removal steps if installed)
- **k3s entirely, Pis untouched**: from the k3s-ansible clone, `ansible-playbook playbooks/reset.yml -i inventory.yml`
