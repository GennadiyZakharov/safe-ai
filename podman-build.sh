#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

podman build --build-arg USER_NAME="$USER" -t safe-ai "$SCRIPT_DIR"
