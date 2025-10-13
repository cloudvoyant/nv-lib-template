FROM ubuntu:22.04

# Install minimal base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    sudo \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy setup scripts
COPY scripts /tmp/scripts

# Run setup.sh with all flags to install all dependencies
# --dev: installs docker, node/npx, gcloud, shellcheck, shfmt
# --template: installs bats-core for testing
RUN cd /tmp/scripts && \
    chmod +x setup.sh && \
    ./setup.sh --dev --template --docker-optimize && \
    rm -rf /tmp/scripts

# Add direnv hook to vscode user's bashrc
RUN echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc && \
    chown vscode:vscode /home/vscode/.bashrc

USER vscode
WORKDIR /workspace
