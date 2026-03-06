# ==============================================================================
# Base stage: Minimal runtime for docker-compose (run/test)
# ==============================================================================
FROM ubuntu:22.04 AS base

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

# Install mise globally
RUN curl https://mise.jdx.dev/install.sh | MISE_INSTALL_PATH=/usr/local/bin/mise sh

# Add mise shims to PATH globally
ENV PATH="/usr/local/share/mise/shims:/usr/local/bin:$PATH"
ENV MISE_DATA_DIR=/usr/local/share/mise

# Install python first (gcloud's installer requires 'python' on PATH),
# then install all remaining tools from mise.toml
COPY mise.toml /tmp/mise.toml
RUN mise install --yes python@latest && \
    cd /tmp && mise install --yes && \
    rm -f /tmp/mise.toml && \
    chown -R vscode:vscode /usr/local/share/mise

USER vscode
WORKDIR /workspaces

# Configure mise for vscode user (trust all configs in /workspaces)
RUN mkdir -p ~/.config/mise && \
    printf '[settings]\ntrusted_config_paths = ["/workspaces"]\n' \
    > ~/.config/mise/config.toml

# ==============================================================================
# Dev stage: Full development environment for DevContainers
# ==============================================================================
FROM base AS dev

USER root

# Configure starship prompt for dev containers
RUN mkdir -p /home/vscode/.config && \
    cat > /home/vscode/.config/starship.toml <<'EOF'
# Starship configuration for dev containers
format = """
[┌───────────────────────────────────────────────────────────>](bold green)
[│](bold green)$directory$git_branch$git_status
[└─>](bold green) """

[directory]
style = "blue bold"
truncation_length = 4
truncate_to_repo = false

[git_branch]
style = "yellow bold"
format = " on [$symbol$branch]($style)"

[git_status]
style = "red bold"
format = '([\[$all_status$ahead_behind\]]($style))'
EOF

# Add mise activate and starship init to vscode user's bashrc
RUN echo 'eval "$(mise activate bash)"' >> /home/vscode/.bashrc && \
    echo 'eval "$(starship init bash)"' >> /home/vscode/.bashrc && \
    chown -R vscode:vscode /home/vscode/.config /home/vscode/.bashrc

USER vscode
WORKDIR /workspaces
