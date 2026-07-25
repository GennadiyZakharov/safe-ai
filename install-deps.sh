#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y podman uidmap

# sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"

if command -v loginctl >/dev/null 2>&1; then
  if ! sudo loginctl enable-linger "$USER"; then
    echo "Warning: failed to enable linger; continuing without linger setup." >&2
  fi
else
  echo "Warning: loginctl not found; skipping linger setup." >&2
fi

podman info | grep rootless
