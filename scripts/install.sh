#!/bin/sh
# Universal installer for chezmoi dotfiles
# Works with both sh and bash
# Usage: 
#   curl -fsSL https://raw.githubusercontent.com/pellpedro/chezmoi/main/scripts/install.sh | sh
#   wget -qO- https://raw.githubusercontent.com/pellpedro/chezmoi/main/scripts/install.sh | sh

set -eu

# Configuration
REPO_URL="git@github.com:pellpedro/chezmoi.git"
REPO_NAME="chezmoi"
INSTALL_DIR="${TMPDIR:-/tmp}/chezmoi-installer-$$"

# Simple logging
log() { printf "[INFO] %s\n" "$*"; }
error() { printf "[ERROR] %s\n" "$*" >&2; }
die() { error "$*"; exit 1; }

# Cleanup function
cleanup() {
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
    fi
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Check for required commands
check_requirements() {
    local missing=""
    
    for cmd in git curl; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing="$missing $cmd"
        fi
    done
    
    if [ -n "$missing" ]; then
        error "Missing required commands:$missing"
        error ""
        error "Please install the missing commands:"
        error "  Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y git curl"
        error "  Fedora/RHEL:   sudo dnf install -y git curl"
        error "  Arch Linux:    sudo pacman -Sy --noconfirm git curl"
        error "  macOS:         xcode-select --install"
        exit 1
    fi
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_TYPE="linux"
        OS_DISTRO="$ID"
    elif [ "$(uname)" = "Darwin" ]; then
        OS_TYPE="darwin"
        OS_DISTRO="darwin"
    else
        OS_TYPE="unknown"
        OS_DISTRO="unknown"
    fi
    
    log "Detected OS: $OS_TYPE ($OS_DISTRO)"
}

# Main installation
main() {
    log "Starting chezmoi dotfiles installation..."
    
    # Check requirements
    check_requirements
    
    # Detect OS
    detect_os
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    
    # Try SSH first, fall back to HTTPS if it fails
    log "Attempting to clone repository..."
    CLONE_URL="$REPO_URL"
    
    # First try with SSH
    if git ls-remote "$CLONE_URL" >/dev/null 2>&1; then
        log "SSH access confirmed, using SSH URL"
    else
        log "SSH access failed, trying HTTPS..."
        CLONE_URL="https://github.com/pellpedro/chezmoi.git"
        
        # Test HTTPS access
        if ! git ls-remote "$CLONE_URL" >/dev/null 2>&1; then
            error "Cannot access repository via SSH or HTTPS"
            error "Please check:"
            error "1. Repository exists and is accessible"
            error "2. For SSH: ssh-agent is running with keys, or SSH keys exist"
            error "3. For private repos: set up SSH authentication"
            die "Repository access failed"
        fi
    fi
    
    # Clone repository
    log "Cloning repository..."
    if ! git clone --depth 1 "$CLONE_URL" "$INSTALL_DIR/$REPO_NAME"; then
        error "Failed to clone repository"
        error ""
        error "If this is a private repository, you need to either:"
        error "1. Set up SSH keys: ssh-keygen -t ed25519 -C 'your-email@example.com'"
        error "2. Add the key to GitHub: https://github.com/settings/keys"
        error "3. Or make the repository public"
        die "Clone failed"
    fi
    
    # Change to scripts directory
    cd "$INSTALL_DIR/$REPO_NAME/scripts" || die "Failed to find scripts directory"
    
    # Make scripts executable
    chmod +x *.sh
    
    # Check if we have bash for the bootstrap script
    if command -v bash >/dev/null 2>&1; then
        log "Running bootstrap script..."
        # Run with provided arguments or default to core and packages
        if [ $# -eq 0 ]; then
            exec bash ./bootstrap.sh core packages
        else
            exec bash ./bootstrap.sh "$@"
        fi
    else
        error "bash is required to run the bootstrap script"
        error "Please install bash first:"
        error "  Ubuntu/Debian: sudo apt-get install -y bash"
        error "  Fedora/RHEL:   sudo dnf install -y bash"
        error "  Arch Linux:    sudo pacman -S --noconfirm bash"
        exit 1
    fi
}

# Run main with all arguments
main "$@"