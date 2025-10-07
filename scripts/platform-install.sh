#!/usr/bin/env bash
: <<DOCUMENTATION
Install platform development dependencies

This script is only needed for platform development/testing.
Scaffolded projects should remove this script.

Installs:
- bats-core: Bash testing framework

Usage:
  bash scripts/platform-install.sh
DOCUMENTATION

# IMPORTS ----------------------------------------------------------------------
source "$(dirname "$0")/utils.sh"
setup_script_lifecycle

# INSTALLATION -----------------------------------------------------------------
log_info "Installing platform development dependencies..."

# Check OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command_exists brew; then
        log_info "Installing bats-core via Homebrew..."
        brew install bats-core
    else
        log_error "Homebrew not found. Install from https://brew.sh"
        exit 1
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command_exists apt-get; then
        log_info "Installing bats-core via apt..."
        sudo apt-get update
        sudo apt-get install -y bats
    elif command_exists yum; then
        log_info "Installing bats-core via yum..."
        sudo yum install -y bats
    else
        log_warn "Package manager not recognized. Installing from source..."
        git clone https://github.com/bats-core/bats-core.git /tmp/bats-core
        cd /tmp/bats-core
        sudo ./install.sh /usr/local
        cd -
        rm -rf /tmp/bats-core
    fi
else
    log_error "Unsupported OS: $OSTYPE"
    exit 1
fi

# VERIFY -----------------------------------------------------------------------
if command_exists bats; then
    log_success "✓ bats-core installed: $(bats --version)"
else
    log_error "Failed to install bats-core"
    exit 1
fi

log_success "✓ Platform development dependencies installed"
