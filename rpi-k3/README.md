# Raspberry Pi k3s Cluster - Quick Start

Companion automation for [How to set up Kubernetes cluster with Raspberry Pi](https://www.entechlog.com/blog/general/how-to-set-up-kubernetes-cluster-with-raspberry-pi/). The blog post has the full narrative (hardware, OS flashing, networking gotchas); this README is the condensed command reference once your Pis are on the network with SSH access.

## Table of Contents
- [Environment: where do things run?](#environment-where-do-things-run)
- [Fresh Install](#fresh-install)
  - [1. Configure the Pis](#1-configure-the-pis)
  - [2. Install k3s](#2-install-k3s)
  - [3. Verify the pod network](#3-verify-the-pod-network)
  - [4. Monitor the cluster](#4-monitor-the-cluster)
  - [5. Optional: Kubernetes Dashboard](#5-optional-kubernetes-dashboard)
- [Reset / Teardown](#reset--teardown)
  - [Remove workloads only](#remove-workloads-only)
  - [Remove k3s entirely (keep the Pis)](#remove-k3s-entirely-keep-the-pis)

## Environment: where do things run?

Every command below is one of these two. Check which one before running it.

| Label | What it means | How to get there |
|---|---|---|
| **On your machine** | Your own Windows/Mac/Linux terminal (WSL counts as this too) - NOT inside any container | Just your normal terminal |
| **Inside `kube-tools`** | The Docker container this repo builds - has `ansible`, `kubectl`, `helm` preinstalled | See below |

To get inside `kube-tools` for the first time:

```bash
# On your machine, from kubernetes-examples/kube-tools/
docker compose up -d
docker exec -it kube-tools /bin/bash
```

That container has your whole `kubernetes-examples/` repo mounted, plus wherever you clone `k3s-ansible` alongside it - so both live inside the same container filesystem. All Ansible commands in this guide run from inside `kube-tools`. The only things that run on your own machine are starting the container itself and the `open-*.sh` scripts (they need to launch **your** browser, which a container can't do).

Every time you start a fresh shell inside `kube-tools` (i.e. every new `docker exec`), set these two - every `ansible-playbook` command in this guide needs them and neither persists on its own:

```bash
export ANSIBLE_PRIVATE_KEY_FILE=/C/Users/<you>/.ssh/id_rsa   # adjust <you> - without this, every Ansible command fails with "Permission denied (publickey,password)"
export ANSIBLE_HOST_KEY_CHECKING=False                       # avoids interactive prompts when a Pi's SSH host key changes (e.g. after a re-flash)
```

## Fresh Install

### 1. Configure the Pis
**Inside `kube-tools`**, `cd kubernetes-examples/rpi-k3/configure/`. Edit `hosts.ini` with your Pis' IPs first, then run in order:

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

### 2. Install k3s
Done via the external [k3s-ansible](https://github.com/k3s-io/k3s-ansible) collection - a **separate clone**, not part of this repo.

**Inside `kube-tools`**, clone it onto the mounted host drive (`/C/...`), *outside* `kubernetes-examples/` - not into the container's own home directory (`~`), which is container-local storage and gets wiped if `kube-tools` is ever recreated (`docker compose down` + `up`):

```bash
cd /C/Users/<you>/VisualStudioCode   # adjust to wherever you keep repos on the host
git clone https://github.com/k3s-io/k3s-ansible k3s-ansible-collection
cd k3s-ansible-collection
ansible-galaxy collection install -r collections/requirements.yml
cp inventory-sample.yml inventory.yml
```

Edit `inventory.yml` - `server`/`agent` host groups with your Pis' IPs, `ansible_user: ubuntu`, a `k3s_version` (check the [releases page](https://github.com/k3s-io/k3s/releases)), and a `token` generated with `openssl rand -base64 64` (don't reuse the same token across clusters, don't commit it). See the blog's [Install k3s](https://www.entechlog.com/blog/general/how-to-set-up-kubernetes-cluster-with-raspberry-pi/#install-k3s) section for the full example and the `ANSIBLE_ROLES_PATH` workaround if you hit `the role 'prereq' was not found` on Windows.

**Still inside `kube-tools`, from the `k3s-ansible-collection` directory:**

```bash
ansible-playbook playbooks/site.yml -i inventory.yml
```

Get the kubeconfig and fix its server address (the collection doesn't do this for you - it'll point at `127.0.0.1` otherwise). Save it under `kube-tools/.kube/` on the mounted drive, **not** `~/.kube/config`  - the latter is container-local and gets wiped if `kube-tools` is ever recreated, and every other command in this guide (monitoring, dashboard) expects `KUBECONFIG` to point at this same persistent file:

```bash
mkdir -p /C/Users/<you>/VisualStudioCode/kubernetes-examples/kube-tools/.kube
scp ubuntu@<master-ip>:~/.kube/config /C/Users/<you>/VisualStudioCode/kubernetes-examples/kube-tools/.kube/config
export KUBECONFIG=/C/Users/<you>/VisualStudioCode/kubernetes-examples/kube-tools/.kube/config
kubectl config set-cluster default --server=https://<master-ip>:6443 --kubeconfig $KUBECONFIG
```

Export that same `KUBECONFIG` line at the start of every new `kube-tools` shell from here on - it doesn't persist between `docker exec` sessions any more than the two `ANSIBLE_*` vars above do.

### 3. Verify the pod network
**Inside `kube-tools`**, back in `kubernetes-examples/rpi-k3/configure/` - run this once, right after the cluster comes up. k3s-agent nodes can come up `Ready` with an incomplete pod network mesh (each agent only learns the server's route, not the other agents'), which silently breaks cross-node pod traffic (e.g. Grafana on one node failing to reach Prometheus on another) without failing the install itself:

```bash
ansible-playbook rpi-k3/configure/07-verify-cluster-network.yml -i rpi-k3/configure/hosts.ini
```

It restarts `k3s-agent` on each node to force Flannel to redo peer discovery, then asserts every node has a route to every other node's pod CIDR - it fails loudly if the mesh is still incomplete rather than reporting false success.

### 4. Monitor the cluster
**Inside `kube-tools`**, with `KUBECONFIG` still exported from step 2, from `kubernetes-examples/`:

```bash
bash rpi-k3/monitoring/install-monitoring.sh
```

```bash
# On your machine (not inside kube-tools) - launches your browser
bash rpi-k3/monitoring/open-monitoring.sh
```

See [`monitoring/README.md`](monitoring/README.md) for resource sizing details and a known unrelated `kubectl top`/metrics-server issue.

### 5. Optional: Kubernetes Dashboard
Not installed by default - see [`dashboard/README.md`](dashboard/README.md).

## Reset / Teardown

### Remove workloads only
```bash
# Inside kube-tools
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete namespace monitoring
```
See the dashboard README for its own removal steps if you installed that too.

### Remove k3s entirely (keep the Pis)
This wipes k3s off all three Pis - not the Pis themselves, and not the SSH/hostname/cgroup setup from [step 1](#1-configure-the-pis), which you won't need to redo.

```bash
# Inside kube-tools, from the k3s-ansible clone from step 2 (e.g. /C/Users/<you>/VisualStudioCode/k3s-ansible-collection - NOT kubernetes-examples/)
ansible-playbook playbooks/reset.yml -i inventory.yml
```

To reinstall afterward, you can skip straight back to [step 2](#2-install-k3s) - `site.yml` uses the same `inventory.yml` you already have.
