#!/usr/bin/env bash
# Chroma→Milvus migration with kubectl port-forward lifecycle
# Usage: ./scripts/migrate-with-pf.sh
#   env overrides: CHROMA_SQLITE_PATH, MIGRATE_BATCH_SIZE, MILVUS_HOST, MILVUS_PORT

set -euo pipefail
cd "$(dirname "$0")/.."

BG_PIDS=""
cleanup() { [ -n "$BG_PIDS" ] && kill $BG_PIDS 2>/dev/null; }
trap cleanup EXIT

# --- Milvus port-forward loop ---
if ! bash -c 'echo >/dev/tcp/localhost/19530' 2>/dev/null; then
  echo "[pf] Starting kubectl port-forward to Milvus..."
  while true; do
    kubectl --context admin@blw -n milvus port-forward svc/milvus 19530:19530 2>/dev/null
    sleep 1
  done &
  BG_PIDS="$BG_PIDS $!"
  sleep 3
fi

# --- Ollama tunnel ---
if ! bash -c 'echo >/dev/tcp/localhost/11434' 2>/dev/null; then
  echo "[pf] Starting cloudflared tunnel to Ollama..."
  cloudflared access tcp --hostname ollama.hive-mcp.com --url localhost:11434 &
  BG_PIDS="$BG_PIDS $!"
  sleep 2
fi

# --- Verify connectivity ---
bash -c 'echo >/dev/tcp/localhost/19530' 2>/dev/null || { echo "ERROR: Milvus not reachable on :19530"; exit 1; }
bash -c 'echo >/dev/tcp/localhost/11434' 2>/dev/null || { echo "ERROR: Ollama not reachable on :11434"; exit 1; }
echo "[ok] Milvus :19530 and Ollama :11434 reachable"

export MILVUS_HOST=localhost
export MILVUS_PORT=19530
export OLLAMA_HOST=http://localhost:11434

# --- Run migration ---
echo "[migrate] Starting Chroma→Milvus sync..."
exec clj -Sdeps "$(cat local.deps.edn)" -M:migrate:sync
