#!/usr/bin/env bash
: <<DOCUMENTATION
Installs deps for local development if not present.
- bash
- just (command runner)
- docker
- direnv (for environment management)
- node/npx (for semantic-release)
DOCUMENTATION

# IMPORTS ----------------------------------------------------------------------
source "$(dirname "$0")/utils.sh"
setup_script_lifecycle

# DEPENDENCY CHECKING ----------------------------------------------------------

# Detect OS platform
detect_platform() {
    case "$(uname -s)" in
    Linux*) PLATFORM=Linux ;;
    Darwin*) PLATFORM=Mac ;;
    CYGWIN*) PLATFORM=Cygwin ;;
    MINGW*) PLATFORM=MinGw ;;
    MSYS*) PLATFORM=Git ;;
    *) PLATFORM="UNKNOWN:${unameOut}" ;;
    esac
    log_info "Detected platform: $PLATFORM"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install bash based on platform
install_bash() {
    log_info "Installing Bash..."

    case $PLATFORM in
    Mac)
        if command_exists brew; then
            brew install bash
        else
            log_warn "Homebrew not found. Please install Bash manually"
            return 1
        fi
        ;;
    Linux)
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y bash
        elif command_exists yum; then
            sudo yum install -y bash
        elif command_exists pacman; then
            sudo pacman -S bash
        else
            log_warn "Unsupported Linux distribution. Please install Bash manually"
            return 1
        fi
        ;;
    *)
        log_warn "Unsupported platform for automatic Bash installation. Please install Bash manually"
        return 1
        ;;
    esac

    log_success "Bash installation completed"
}

# Install just based on platform
install_just() {
    log_info "Installing just..."

    case $PLATFORM in
    Mac)
        if command_exists brew; then
            brew install just
        else
            log_warn "Homebrew not found. Installing just from binary..."
            curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin
            log_info "Add ~/bin to your PATH if not already present"
        fi
        ;;
    Linux)
        if command_exists cargo; then
            cargo install just
        elif command_exists apt-get; then
            # Install from binary for latest version
            curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin
        else
            log_warn "Installing just from binary..."
            curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin
            log_info "Add ~/bin to your PATH if not already present"
        fi
        ;;
    *)
        log_warn "Unsupported platform for automatic just installation. Please install just manually from https://just.systems"
        return 1
        ;;
    esac

    log_success "just installation completed"
}

# Install Docker based on platform
install_docker() {
    log_info "Installing Docker..."

    case $PLATFORM in
    Mac)
        if command_exists brew; then
            brew install --cask docker
        else
            log_warn "Homebrew not found. Please install Docker Desktop manually from https://docker.com/products/docker-desktop"
            return 1
        fi
        ;;
    Linux)
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y docker.io docker-compose
            sudo systemctl start docker
            sudo systemctl enable docker
        elif command_exists yum; then
            sudo yum install -y docker docker-compose
            sudo systemctl start docker
            sudo systemctl enable docker
        elif command_exists pacman; then
            sudo pacman -S docker docker-compose
            sudo systemctl start docker
            sudo systemctl enable docker
        else
            log_warn "Unsupported Linux distribution. Please install Docker manually from https://docs.docker.com/engine/install/"
            return 1
        fi
        ;;
    *)
        log_warn "Unsupported platform for automatic Docker installation. Please install Docker manually from https://docker.com"
        return 1
        ;;
    esac

    log_success "Docker installation completed"
}

# Install direnv based on platform
install_direnv() {
    log_info "Installing direnv..."

    case $PLATFORM in
    Mac)
        if command_exists brew; then
            brew install direnv
        else
            log_warn "Homebrew not found. Please install direnv manually from https://direnv.net/docs/installation.html"
            return 1
        fi
        ;;
    Linux)
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y direnv
        elif command_exists yum; then
            sudo yum install -y direnv
        elif command_exists pacman; then
            sudo pacman -S direnv
        elif command_exists curl; then
            # Install from binary release
            ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
            curl -sfL https://direnv.net/install.sh | bash
        else
            log_warn "No suitable package manager found. Please install direnv manually from https://direnv.net/docs/installation.html"
            return 1
        fi
        ;;
    *)
        log_warn "Unsupported platform for automatic direnv installation. Please install direnv manually from https://direnv.net/docs/installation.html"
        return 1
        ;;
    esac

    log_success "direnv installation completed"
    log_info "Please add 'eval \"\$(direnv hook bash)\"' to your ~/.bashrc or shell config"
}

# Install Node.js and npx based on platform
install_node() {
    log_info "Installing Node.js..."

    case $PLATFORM in
    Mac)
        if command_exists brew; then
            brew install node
        else
            log_warn "Homebrew not found. Please install Node.js manually from https://nodejs.org"
            return 1
        fi
        ;;
    Linux)
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y nodejs npm
        elif command_exists yum; then
            sudo yum install -y nodejs npm
        elif command_exists pacman; then
            sudo pacman -S nodejs npm
        else
            log_warn "No suitable package manager found. Please install Node.js manually from https://nodejs.org"
            return 1
        fi
        ;;
    *)
        log_warn "Unsupported platform for automatic Node.js installation. Please install Node.js manually from https://nodejs.org"
        return 1
        ;;
    esac

    log_success "Node.js installation completed"
}

# Check and install dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    local total=5
    local current=0

    # Check Bash
    current=$((current + 1))
    progress_step $current $total "Checking Bash..."
    if command_exists bash; then
        log_success "Bash is already installed: $(bash --version | head -n1)"
    else
        log_warn "Bash not found"
        if install_bash; then
            log_success "Bash installed successfully"
        else
            log_error "Failed to install Bash - please install manually and re-run setup"
            exit 1
        fi
    fi

    # Check just
    current=$((current + 1))
    progress_step $current $total "Checking just..."
    if command_exists just; then
        log_success "just is already installed: $(just --version)"
    else
        log_warn "just not found"
        if install_just; then
            log_success "just installed successfully"
        else
            log_error "Failed to install just - visit https://just.systems to install manually and re-run setup"
            exit 1
        fi
    fi

    # Check Docker
    current=$((current + 1))
    progress_step $current $total "Checking Docker..."
    if command_exists docker; then
        log_success "Docker is already installed: $(docker --version)"
    else
        log_warn "Docker not found"
        if install_docker; then
            log_success "Docker installed successfully"
        else
            log_error "Failed to install Docker - visit https://docker.com to install manually and re-run setup"
            exit 1
        fi
    fi

    # Check direnv
    current=$((current + 1))
    progress_step $current $total "Checking direnv..."
    if command_exists direnv; then
        log_success "direnv is already installed: $(direnv --version)"
    else
        log_warn "direnv not found"
        if install_direnv; then
            log_success "direnv installed successfully"
        else
            log_error "Failed to install direnv - visit https://direnv.net to install manually and re-run setup"
            exit 1
        fi
    fi

    # Check Node.js and npx
    current=$((current + 1))
    progress_step $current $total "Checking Node.js and npx..."
    if command_exists npx; then
        log_success "Node.js and npx are already installed: $(node --version)"
    else
        log_warn "Node.js/npx not found (required for semantic-release)"
        if install_node; then
            log_success "Node.js installed successfully"
        else
            log_error "Failed to install Node.js - visit https://nodejs.org to install manually and re-run setup"
            exit 1
        fi
    fi

    # Allow direnv if .envrc exists and is not already allowed
    if [ -f "$(dirname "$0")/../.envrc" ]; then
        if ! direnv status "$(dirname "$0")/.." 2>/dev/null | grep -q "Found RC allowed 0"; then
            log_info "Running direnv allow..."
            direnv allow "$(dirname "$0")/.." >/dev/null 2>&1
            log_success "direnv allow completed"
        else
            log_success "direnv already allowed for this directory"
        fi
    fi

    log_success "All dependencies checked"
}

# MAIN -------------------------------------------------------------------------

detect_platform
check_dependencies

log_info "Setup complete! Run 'just build' to build, 'just test' to run tests, or 'just --list' to see all commands."
