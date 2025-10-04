FROM ubuntu:24.04

# Install minimal base dependencies
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER vscode
WORKDIR /workspace