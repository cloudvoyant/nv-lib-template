FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl ca-certificates python3 \
    && ln -sf /usr/bin/python3 /usr/local/bin/python \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"

RUN curl https://mise.run | sh

# Pre-install all tools declared in mise.toml
COPY mise.toml /workspace/mise.toml
RUN cd /workspace && mise trust && mise install --yes

WORKDIR /workspace
