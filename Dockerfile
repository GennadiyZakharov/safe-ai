FROM ubuntu:26.04

# Avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
# Overrided by argument passed by the build script
ARG USER_NAME=ubuntu

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash ca-certificates coreutils findutils procps socat \
    build-essential python3-pip python3-venv ripgrep fd-find git \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Create the user to match your host user name
# We don't need to fix permissions here; Podman maps it at runtime.
RUN if [ "$USER_NAME" != "ubuntu" ]; then \
      groupmod -n "$USER_NAME" ubuntu \
      && usermod -l "$USER_NAME" -d "/home/$USER_NAME" -m ubuntu; \
    fi \
    && usermod -s /bin/bash "$USER_NAME"
USER $USER_NAME
WORKDIR /home/$USER_NAME/programming

# Entrypoint setup
COPY --chown=$USER_NAME:$USER_NAME safe-ai-entrypoint.sh /usr/local/bin/safe-ai-entrypoint.sh
RUN chmod +x /usr/local/bin/safe-ai-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/safe-ai-entrypoint.sh"]
