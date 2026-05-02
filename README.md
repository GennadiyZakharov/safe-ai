# Safe-AI

Safe-AI is a small Podman-based sandbox for running AI coding tools against a
development workspace with a narrower view of the host machine.

It starts an Ubuntu container, mounts `~/programming` as the writable workspace,
mounts selected home-directory files and folders as read-only, and stores the
AI tool configuration in a separate persistent directory.

## What It Does

- Runs a disposable Podman container named `safe-ai`.
- Mounts your `~/programming` directory read-write inside the container.
- Persists Codex configuration in `~/.codex-docker`.
- Mounts selected host files and tool directories read-only.
- Exposes a local host LLM endpoint inside the container at `127.0.0.1:8000`.

## Repository Contents

- `safe-ai` - launcher script that validates the current directory and starts
  the container.
- `Dockerfile` - Ubuntu 24.04 image with common development tools installed.
- `safe-ai-entrypoint.sh` - container entrypoint that prepares the environment
  and optional local LLM proxy.
- `podman-build.sh` - builds the container image as `safe-ai`.
- `install-deps.sh` - installs Podman-related dependencies on Debian/Ubuntu
  systems.

## Requirements

- Linux host
- Podman
- Rootless Podman support
- A development workspace at `~/programming`

This project currently contains host-specific assumptions, including the user
name `gena` in the `Dockerfile` and entrypoint `PATH`. Update those values if
you use this on a different account.

## Install Dependencies

On Debian or Ubuntu:

```bash
./install-deps.sh
```

The script installs:

- `podman`
- `podman-docker`
- `uidmap`

### Build The Image

```bash
./podman-build.sh
```

This builds the local image `safe-ai`

## Run The Sandbox

Start from a project inside `~/programming`:

```bash
cd ~/programming/my-project
./path/to/safe-ai
```

The container starts in the matching path under:

```bash
/home/$USER/programming
```

If you run the launcher outside `~/programming`, it exits without starting the
container.

Edit the arrays in `safe-ai` to change which host paths are exposed.

## Local LLM Proxy

By default, the entrypoint maps container-local requests from:

```bash
127.0.0.1:8000
```

to the host endpoint:

```bash
host.containers.internal:8000
```

It also exports:

```bash
LOCAL_LLM_BASE_URL=http://127.0.0.1:8000
LOCAL_LLM_OPENAI_BASE_URL=http://127.0.0.1:8000/v1
```

You can override the proxy settings with environment variables:

```bash
LOCAL_LLM_PROXY_TARGET_HOST=host.containers.internal
LOCAL_LLM_PROXY_TARGET_PORT=8000
LOCAL_LLM_PROXY_LISTEN_PORT=8000
ENABLE_LOCAL_LLM_PROXY=1
```

## Security Model

Safe-AI is intended to reduce accidental writes to sensitive host files while
keeping the normal development workspace available.

Important limits:

- Anything under `~/programming` is writable by the container.
- Read-only mounts protect only the paths listed in `safe-ai`.
- This is not a hardened isolation boundary for running untrusted code.
- The container has normal network access unless Podman or the host blocks it.

Review the mounted paths before using this with private projects or credentials.