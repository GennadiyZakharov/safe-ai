FROM ubuntu:26.04

# Avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash ca-certificates coreutils findutils procps socat \
    build-essential python3-pip python3-venv ripgrep fd-find git  \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Create the user to match your host user name
# We don't need to fix permissions here; Podman maps it at runtime.
RUN groupmod -n gena ubuntu && usermod -l gena -d /home/gena -m ubuntu && usermod -s /bin/bash gena
USER gena
WORKDIR /home/gena/programming

# Entrypoint setup
COPY --chown=gena:gena safe-ai-entrypoint.sh /usr/local/bin/safe-ai-entrypoint.sh
RUN chmod +x /usr/local/bin/safe-ai-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/safe-ai-entrypoint.sh"]