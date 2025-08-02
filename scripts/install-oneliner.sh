#!/bin/bash
# Single-file installer for chezmoi dotfiles
# Usage: curl -fsSL https://raw.githubusercontent.com/PellPedro/chezmoi/main/scripts/install-oneliner.sh | bash

set -euo pipefail

# Configuration
CHEZMOI_REPO="https://github.com/PellPedro/chezmoi.git"
CHEZMOI_VERSION="v2.63.1"
GO_VERSION="1.23.4"
NODE_VERSION="v24.4.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
abort() { error "$1"; exit 1; }

# Detect system
detect_system() {
    OS=""
    ARCH=""
    DISTRO=""
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian) DISTRO="ubuntu" ;;
                fedora|rhel|centos) DISTRO="fedora" ;;
                arch|manjaro) DISTRO="arch" ;;
                *) DISTRO="unknown" ;;
            esac
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="darwin"
        DISTRO="darwin"
    else
        abort "Unsupported OS: $OSTYPE"
    fi
    
    # Detect architecture
    local arch=$(uname -m)
    case "$arch" in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) abort "Unsupported architecture: $arch" ;;
    esac
    
    log "Detected: OS=$OS, Arch=$ARCH, Distribution=$DISTRO"
}

# Install base dependencies
install_base_deps() {
    log "Installing base dependencies..."
    
    case "$DISTRO" in
        ubuntu)
            sudo apt-get update
            sudo apt-get install -y curl wget git build-essential
            ;;
        fedora)
            sudo dnf install -y curl wget git gcc gcc-c++ make
            ;;
        arch)
            sudo pacman -Sy --needed --noconfirm curl wget git base-devel
            ;;
        darwin)
            if ! xcode-select -p >/dev/null 2>&1; then
                log "Installing Xcode Command Line Tools..."
                xcode-select --install
                log "Please wait for Xcode installation to complete, then re-run this script"
                exit 0
            fi
            ;;
    esac
}

# Install Homebrew
install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH
        case "$OS" in
            darwin)
                if [[ "$ARCH" == "arm64" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
                ;;
            linux)
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                ;;
        esac
    fi
}

# Install chezmoi
install_chezmoi() {
    log "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
}

# Install essential tools
install_essential_tools() {
    log "Installing essential tools..."
    
    # Install age
    if ! command -v age >/dev/null 2>&1; then
        brew install age
    fi
    
    # Install gopass
    if ! command -v gopass >/dev/null 2>&1; then
        brew install gopass
    fi
    
    # Install Rust
    if ! command -v rustc >/dev/null 2>&1; then
        log "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        source "$HOME/.cargo/env"
    fi
    
    # Install Atuin
    if ! command -v atuin >/dev/null 2>&1; then
        log "Installing Atuin..."
        bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
    fi
    
    # Install zoxide
    if ! command -v zoxide >/dev/null 2>&1; then
        log "Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi
}

# Clone and apply chezmoi
setup_chezmoi() {
    log "Setting up chezmoi..."
    
    # Initialize chezmoi with your repo
    "$HOME/.local/bin/chezmoi" init --apply "$CHEZMOI_REPO"
}

# Main installation
main() {
    log "Starting chezmoi dotfiles installation..."
    
    # Create necessary directories
    mkdir -p "$HOME/.local/bin"
    
    # Detect system
    detect_system
    
    # Install dependencies
    install_base_deps
    
    # Install package managers
    install_homebrew
    
    # Install chezmoi
    install_chezmoi
    
    # Install essential tools
    install_essential_tools
    
    # Setup chezmoi
    setup_chezmoi
    
    success "Installation completed!"
    echo ""
    echo "Next steps:"
    echo "1. Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
    echo "2. Run: chezmoi update"
    echo ""
    echo "For full installation of all tools (Go, Node.js, Java, etc.), run:"
    echo "  cd ~/$(basename $CHEZMOI_REPO .git)/scripts"
    echo "  ./bootstrap.sh"
}

# Run main
main "$@"