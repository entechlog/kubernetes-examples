#!/usr/bin/env bash
# Opens an SSH tunnel to Grafana, prints the admin password, and opens it in
# your browser. Run this on your own machine (not inside a container).
# Ctrl+C stops the tunnel and closes access.
set -euo pipefail

MASTER_HOST="${MASTER_HOST:-ubuntu@192.168.0.100}"
LOCAL_PORT="${LOCAL_PORT:-3000}"
WIN_KEY="/mnt/c/Users/nadesansiva/.ssh/id_rsa"
WSL_KEY="${HOME}/.ssh/id_rsa_pi"

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

echo "Fetching Grafana admin password..."
PASSWORD=$(ssh "${SSH_OPTS[@]}" "$MASTER_HOST" \
  "sudo k3s kubectl -n monitoring get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d")
echo
echo "Username: admin"
echo "Password: $PASSWORD"
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

echo "Opening tunnel on http://localhost:${LOCAL_PORT} (Ctrl+C to stop)..."
ssh "${SSH_OPTS[@]}" -L "${LOCAL_PORT}:localhost:${LOCAL_PORT}" "$MASTER_HOST" \
  "sudo k3s kubectl -n monitoring port-forward --address 0.0.0.0 svc/kube-prometheus-stack-grafana ${LOCAL_PORT}:80" &
SSH_PID=$!

echo "Waiting for tunnel to come up..."
for _ in $(seq 1 30); do
  if (exec 3<>"/dev/tcp/localhost/${LOCAL_PORT}") 2>/dev/null; then
    exec 3>&-
    break
  fi
  sleep 1
done

open_browser "http://localhost:${LOCAL_PORT}"
wait "$SSH_PID"
