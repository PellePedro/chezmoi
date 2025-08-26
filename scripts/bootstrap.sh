#!/bin/bash

set -euo pipefail

# Bootstrap script for chezmoi dotfiles
# Supports: Darwin (macOS), Ubuntu/Debian, Fedora/RHEL, Arch Linux
# Architectures: amd64, arm64/aarch64

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

abort() {
  error "$1"
  exit 1
}

# Detect OS and architecture
detect_system() {
  local os=""
  local arch=""
  local distro=""
  
  # Detect OS
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    os="linux"
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case "$ID" in
        ubuntu|debian)
          distro="ubuntu"
          ;;
        fedora|rhel|centos|rocky|almalinux)
          distro="fedora"
          ;;
        arch|manjaro)
          distro="arch"
          ;;
        *)
          distro="unknown"
          ;;
      esac
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    os="darwin"
    distro="darwin"
  else
    abort "Unsupported OS: $OSTYPE"
  fi
  
  # Detect architecture
  local machine_arch=$(uname -m)
  case "$machine_arch" in
    x86_64)
      arch="amd64"
      ;;
    aarch64|arm64)
      arch="arm64"
      ;;
    *)
      abort "Unsupported architecture: $machine_arch"
      ;;
  esac
  
  echo "$os|$arch|$distro"
}

# Check if running with sudo (when not needed)
check_sudo() {
  if [ "$EUID" -eq 0 ]; then
    error "Please do not run this script with sudo"
    error "The script will request sudo permissions when needed"
    exit 1
  fi
}

# Verify script dependencies
verify_scripts() {
  local required_scripts=(
    "install-core.sh"
    "install-packages.sh"
    "install-go.sh"
    "install-node.sh"
    "install-sdkman.sh"
    "install-neovim.sh"
    "install-nerdfonts.sh"
  )
  
  for script in "${required_scripts[@]}"; do
    if [ ! -f "$SCRIPT_DIR/$script" ]; then
      abort "Required script not found: $script"
    fi
    
    if [ ! -x "$SCRIPT_DIR/$script" ]; then
      log "Making $script executable"
      chmod +x "$SCRIPT_DIR/$script"
    fi
  done
}

# Interactive mode to select components
select_components() {
  log "Select components to install:" >&2
  echo "" >&2
  
  local components=(
    "core:Core tools (chezmoi, age, gopass, homebrew, uv, atuin, rust, zoxide)"
    "packages:System packages and development tools"
    "go:Go programming language and tools"
    "node:Node.js via fnm and npm packages"
    "java:Java via SDKMAN with Maven and Gradle"
    "neovim:Neovim (build from source)"
    "nerdfonts:JetBrains Mono Nerd Font"
  )
  
  local selected=()
  
  for component in "${components[@]}"; do
    IFS=':' read -r key desc <<< "$component"
    echo "" >&2
    echo "Install $desc? [Y/n]" >&2
    read -r REPLY
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
      selected+=("$key")
    fi
  done
  
  if [ ${#selected[@]} -gt 0 ]; then
    echo "${selected[@]}"
  else
    echo ""
  fi
}

# Run installation scripts
run_installations() {
  local components=("$@")
  
  for component in "${components[@]}"; do
    case "$component" in
      core)
        log "Installing core tools..."
        "$SCRIPT_DIR/install-core.sh" || warn "Core tools installation had issues"
        success "Core tools installation completed"
        ;;
      packages)
        log "Installing system packages..."
        "$SCRIPT_DIR/install-packages.sh" || warn "Package installation had issues"
        success "Package installation completed"
        ;;
      go)
        log "Installing Go..."
        "$SCRIPT_DIR/install-go.sh" || warn "Go installation had issues"
        success "Go installation completed"
        ;;
      node)
        log "Installing Node.js..."
        "$SCRIPT_DIR/install-node.sh" || warn "Node.js installation had issues"
        success "Node.js installation completed"
        ;;
      java)
        log "Installing Java/SDKMAN..."
        "$SCRIPT_DIR/install-sdkman.sh" || warn "SDKMAN installation had issues"
        success "Java/SDKMAN installation completed"
        ;;
      neovim)
        log "Building Neovim from source..."
        "$SCRIPT_DIR/install-neovim.sh" || warn "Neovim build had issues"
        success "Neovim build completed"
        ;;
      nerdfonts)
        log "Installing Nerd Fonts..."
        "$SCRIPT_DIR/install-nerdfonts.sh" || warn "Nerd Fonts installation had issues"
        success "Nerd Fonts installation completed"
        ;;
    esac
    echo ""
  done
}

# Post-installation setup
post_install() {
  log "Post-installation setup..."
  
  # Add PATH exports to shell config
  local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc")
  local path_exports=(
    'export PATH="$HOME/.local/bin:$PATH"'
    'export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"'
    'export PATH="$HOME/.cargo/bin:$PATH"'
  )
  
  for config in "${shell_configs[@]}"; do
    if [ -f "$config" ]; then
      for export_line in "${path_exports[@]}"; do
        if ! grep -q "$export_line" "$config" 2>/dev/null; then
          echo "$export_line" >> "$config"
        fi
      done
    fi
  done
  
  # Create common directories
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share"
  
  success "Post-installation setup completed"
}

# Print summary
print_summary() {
  echo ""
  log "Installation Summary"
  echo "===================="
  
  # Check installed tools
  local tools=(
    "chezmoi:Chezmoi"
    "age:Age encryption"
    "gopass:Gopass"
    "brew:Homebrew"
    "uv:uv (Python)"
    "go:Go"
    "node:Node.js"
    "java:Java"
    "mvn:Maven"
    "gradle:Gradle"
    "nvim:Neovim"
  )
  
  for tool_info in "${tools[@]}"; do
    IFS=':' read -r cmd name <<< "$tool_info"
    if command -v "$cmd" &> /dev/null; then
      success "$name is installed"
    else
      warn "$name is not installed or not in PATH"
    fi
  done
  
  echo ""
  log "Next steps:"
  echo "1. Restart your shell or source your shell configuration"
  echo "2. Run 'chezmoi init' to initialize your dotfiles"
  echo "3. Run 'chezmoi apply' to apply your configuration"
}

# Main function
main() {
  # Only clear if running interactively
  if [ -t 0 ]; then
    clear
  fi
  echo "========================================"
  echo "Chezmoi Dotfiles Bootstrap"
  echo "========================================"
  echo ""
  
  # Check system
  check_sudo
  
  # Detect system info
  IFS='|' read -r os arch distro <<< "$(detect_system)"
  log "Detected system: OS=$os, Arch=$arch, Distribution=$distro"
  echo ""
  
  # Verify required scripts
  verify_scripts
  
  # Select components
  if [ $# -eq 0 ]; then
    # Interactive mode
    selected_output=$(select_components)
    if [ -z "$selected_output" ]; then
      components=()
    else
      read -ra components <<< "$selected_output"
    fi
  else
    # Use command line arguments
    components=("$@")
  fi
  
  if [ ${#components[@]} -eq 0 ]; then
    warn "No components selected. Exiting."
    exit 0
  fi
  
  echo ""
  log "Installing selected components: ${components[*]}"
  echo ""
  
  # Run installations
  run_installations "${components[@]}"
  
  # Post-installation setup
  post_install
  
  # Print summary
  print_summary
  
  # Add PATH reminder for Rust
  if [[ " ${components[@]} " =~ " core " ]]; then
    echo ""
    echo "Don't forget to add Rust to your PATH:"
    echo 'export PATH="$HOME/.cargo/bin:$PATH"'
  fi
}

# Run main function with all arguments
main "$@"