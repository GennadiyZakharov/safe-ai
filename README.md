# Safe-AI

Safe-AI is a small Podman-based sandbox for running AI coding tools against a
development workspace with a narrower view of the host machine.

It starts an Ubuntu container, mounts the current repository as the writable
workspace, mounts selected home-directory files and folders as read-only, and
stores the AI tool configuration in a separate persistent directory.

## What It Does

- Runs a disposable Podman container named `safe-ai`.
- Mounts the current Git repository read-write inside the container.
- Persists Codex configuration in `~/.codex-docker`.
- Mounts selected host files and tool directories read-only.
- Exposes a local host LLM endpoint inside the container at `127.0.0.1:8100`.

## Repository Contents

- `safe-ai` - launcher script that validates the current directory and starts
  the container.
- `Dockerfile` - Ubuntu 26.04 image with common development tools installed.
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

The image build uses your host `$USER` as the container user name, so rebuild
the image on each host account that will run the sandbox.

## Install Dependencies

On Debian or Ubuntu:

```bash
./install-deps.sh
```

The script installs:

- `podman`
- `uidmap`

### Build The Image

```bash
./podman-build.sh
```

This builds the local image `safe-ai`

The build script passes `--build-arg USER_NAME="$USER"` so the container user
matches your host user name.

## Run The Sandbox

Start from a project inside `~/programming`:

```bash
cd ~/programming/my-project
./path/to/safe-ai
```

By default, the launcher mounts only the current Git repository read-write. If
you run it from a directory that is not inside a Git repository, it mounts the
current directory instead. The container starts in the matching path under:

```bash
/home/$USER/programming
```

If you run the launcher outside `~/programming`, it exits without starting the
container.

Set `SAFE_AI_MOUNT_SCOPE=programming` when a task really needs write access to
all projects under `~/programming`:

```bash
SAFE_AI_MOUNT_SCOPE=programming ./path/to/safe-ai
```

Edit the arrays in `safe-ai` to change which host home paths are exposed
read-only.

Read-only home mounts are mounted without SELinux relabeling by default. If your
host requires relabeling for those mounts, set `SAFE_AI_READONLY_LABEL` to `z`
or `Z`.

## Local LLM Proxy

By default, the entrypoint maps container-local requests from:

```bash
127.0.0.1:8100
```

to the host endpoint:

```bash
host.containers.internal:8100
```

It also exports:

```bash
LOCAL_LLM_BASE_URL=http://127.0.0.1:8100
LOCAL_LLM_OPENAI_BASE_URL=http://127.0.0.1:8100/v1
```

You can override the proxy settings with environment variables:

```bash
LOCAL_LLM_PROXY_TARGET_HOST=host.containers.internal
LOCAL_LLM_PROXY_TARGET_PORT=8100
LOCAL_LLM_PROXY_LISTEN_PORT=8100
ENABLE_LOCAL_LLM_PROXY=1
```

## Security Model

Safe-AI is intended to reduce accidental writes to sensitive host files while
keeping the normal development workspace available.

Important limits:

- By default, only the active repository or current directory is writable by the
  container.
- If `SAFE_AI_MOUNT_SCOPE=programming` is set, anything under `~/programming`
  is writable by the container.
- Read-only mounts protect only the paths listed in `safe-ai`.
- This is not a hardened isolation boundary for running untrusted code.
- The container has normal network access unless Podman or the host blocks it.

Review the mounted paths before using this with private projects or credentials.
