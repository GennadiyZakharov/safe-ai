#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y podman uidmap

# sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"

sudo loginctl enable-linger "$USER"

podman info | grep rootless

