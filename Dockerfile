FROM ubuntu:26.04

# Avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
# Overridden by argument passed by the build script
ARG USER_NAME=ubuntu

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash ca-certificates coreutils findutils procps socat \
    build-essential python3-pip python3-venv ripgrep fd-find git \
    rsync \
    libnss3 libnspr4 \
    libatk1.0-0t64 libatk-bridge2.0-0t64 libatspi2.0-0t64 \
    libcups2t64 \
    libdbus-1-3 libglib2.0-0t64 \
    libx11-6 libxcb1 libxext6 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libgbm1 libdrm2 \
    libpango-1.0-0 libcairo2 \
    libasound2t64 libwayland-client0 \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
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
