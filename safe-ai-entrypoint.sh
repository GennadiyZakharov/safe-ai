#!/usr/bin/env bash
set -euo pipefail

# In Podman, host.containers.internal is the standard way to reach the host.
# This avoids issues if your network bridge IP changes.
TARGET_HOST="${LOCAL_LLM_PROXY_TARGET_HOST:-host.containers.internal}"
TARGET_PORT="${LOCAL_LLM_PROXY_TARGET_PORT:-8100}"
LISTEN_PORT="${LOCAL_LLM_PROXY_LISTEN_PORT:-8100}"

if [[ "${ENABLE_LOCAL_LLM_PROXY:-1}" == "1" ]]; then
  echo "🔗 Mapping container 127.0.0.1:$LISTEN_PORT -> host $TARGET_HOST:$TARGET_PORT"

  # The socat bridge remains the most compatible way for tools expecting 'localhost'
  socat "TCP-LISTEN:${LISTEN_PORT},bind=127.0.0.1,fork,reuseaddr" "TCP:${TARGET_HOST}:${TARGET_PORT}" &

  export LOCAL_LLM_BASE_URL="http://127.0.0.1:${LISTEN_PORT}"
  export LOCAL_LLM_OPENAI_BASE_URL="http://127.0.0.1:${LISTEN_PORT}/v1"
fi

export PATH=$PATH:/home/gena/.local/bin
echo "✅ Environment ready. Path: $PATH"

# Execute whatever command was passed, or fall back to bash
if [ $# -eq 0 ]; then
    exec /usr/bin/bash
else
    exec "$@"
fi