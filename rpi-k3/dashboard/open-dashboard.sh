#!/usr/bin/env bash
# Opens an SSH tunnel to the Kubernetes Dashboard, prints a fresh login token, and
# opens the dashboard in your browser. Run this on your own machine (not inside a container).
# Ctrl+C stops the tunnel and closes access.
set -euo pipefail

MASTER_HOST="${MASTER_HOST:-ubuntu@192.168.0.100}"
LOCAL_PORT="${LOCAL_PORT:-8443}"
WIN_KEY="/mnt/c/Users/nadesansiva/.ssh/id_rsa"
WSL_KEY="${HOME}/.ssh/id_rsa_pi"

# SSH refuses keys with group/world-readable permissions, and files under /mnt/c
# (Windows filesystem) can't be chmod'd strictly enough from WSL. Self-heal by
# caching a properly-permissioned copy in WSL's native filesystem on first run.
if [ ! -f "$WSL_KEY" ] && [ -f "$WIN_KEY" ]; then
  echo "Copying SSH key into WSL-native storage (one-time)..."
  mkdir -p "$(dirname "$WSL_KEY")"
  cp "$WIN_KEY" "$WSL_KEY"
  chmod 600 "$WSL_KEY"
fi

SSH_KEY="${SSH_KEY:-$WSL_KEY}"
SSH_OPTS=(-o ConnectTimeout=5)
if [ -f "$SSH_KEY" ]; then
  SSH_OPTS+=(-i "$SSH_KEY")
fi

echo "Fetching login token..."
TOKEN=$(ssh "${SSH_OPTS[@]}" "$MASTER_HOST" "sudo k3s kubectl -n kubernetes-dashboard create token admin-user")
echo
echo "Token:"
echo "$TOKEN"
echo

open_browser() {
  local url=$1
  if command -v cmd.exe >/dev/null 2>&1; then
    cmd.exe /c start "$url" >/dev/null 2>&1 &
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url" >/dev/null 2>&1 &
  elif command -v open >/dev/null 2>&1; then
    open "$url" >/dev/null 2>&1 &
  fi
}

echo "Opening tunnel on https://localhost:${LOCAL_PORT} (Ctrl+C to stop)..."
ssh "${SSH_OPTS[@]}" -L "${LOCAL_PORT}:localhost:8443" "$MASTER_HOST" \
  "sudo k3s kubectl -n kubernetes-dashboard port-forward --address 0.0.0.0 svc/kubernetes-dashboard-kong-proxy 8443:443" &
SSH_PID=$!

echo "Waiting for tunnel to come up..."
for _ in $(seq 1 30); do
  if (exec 3<>"/dev/tcp/localhost/${LOCAL_PORT}") 2>/dev/null; then
    exec 3>&-
    break
  fi
  sleep 1
done

open_browser "https://localhost:${LOCAL_PORT}"
wait "$SSH_PID"
