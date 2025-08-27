#!/usr/bin/env bash

set -euo pipefail

# chezmoi url
chezmoi_url="git@github.com:pellpedro/chezmoi.git"

# Add $HOME/.local/bin to PATH at the beginning
export PATH="$HOME/.local/bin:$PATH"

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly USER_BIN="$HOME/.local/bin"
readonly TEMP_DIR="/tmp/dotfiles-install-$$"

# Tool versions
readonly CHEZMOI_VERSION="v2.24.0"

# Global variables
OS=""
ARCH="amd64"

# Cleanup function
cleanup() {
  local exit_code=$?
  if [[ -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
  exit $exit_code
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Logging functions
log() {
  printf "\n=== %s ===\n" "$*"
}

info() {
  printf "[INFO] %s\n" "$*"
}

error() {
  printf "[ERROR] %s\n" "$*" >&2
}

abort() {
  error "$*"
  exit 1
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check required tools
check_required_tools() {
  local missing_tools=()
  local required_tools=(curl gunzip tar chmod rm printf mv mkdir)

  for tool in "${required_tools[@]}"; do
    if ! command_exists "$tool"; then
      missing_tools+=("$tool")
    fi
  done

  if [[ ${#missing_tools[@]} -gt 0 ]]; then
    abort "Missing required tools: ${missing_tools[*]}"
  fi
}

# Detect system architecture
get_arch() {
  local arch
  arch=$(uname -m)
  case "$arch" in
  x86_64 | amd64)
    ARCH="amd64"
    ;;
  arm64 | aarch64)
    ARCH="arm64"
    ;;
  armv7l)
    ARCH="armv7"
    ;;
  *)
    abort "Unsupported architecture: $arch"
    ;;
  esac
  info "Detected architecture: $ARCH"
}

# Detect operating system
get_os() {
  if [[ "$OSTYPE" =~ darwin* ]]; then
    OS="darwin"
    info "Running on macOS"
  elif uname -a | grep -qi nixos; then
    OS="nixos"
    info "Running on NixOS"
  elif [[ "$OSTYPE" =~ linux* ]]; then
    OS="linux"
    info "Running on Linux"
  else
    abort "Unsupported operating system: $OSTYPE"
  fi
}

# Create necessary directories
setup_directories() {
  info "Setting up directories"
  mkdir -p "$USER_BIN" "$TEMP_DIR"

  # Add USER_BIN to PATH if not already there
  if [[ ":$PATH:" != *":$USER_BIN:"* ]]; then
    export PATH="$USER_BIN:$PATH"
    info "Added $USER_BIN to PATH for this session"
  fi
}

# Download and install chezmoi
install_chezmoi() {
  if command_exists chezmoi; then
    info "chezmoi already installed, skipping"
    return 0
  fi

  log "Installing chezmoi $CHEZMOI_VERSION"
  local url="https://github.com/twpayne/chezmoi/releases/download/${CHEZMOI_VERSION}/chezmoi-${OS}-${ARCH}"
  local target="$USER_BIN/chezmoi"

  if ! curl -fsSL "$url" -o "$target"; then
    abort "Failed to download chezmoi from $url"
  fi

  chmod +x "$target"
  info "chezmoi installed successfully"
}

# Install Homebrew (macOS only)
install_homebrew() {
  if [[ "$OS" != "darwin" ]]; then
    return 0
  fi

  if command_exists brew; then
    info "Homebrew already installed, skipping"
    return 0
  fi

  log "Installing Homebrew"
  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    abort "Failed to install Homebrew"
  fi
  info "Homebrew installed successfully"
}

# Initialize chezmoi with dotfiles repository
init_chezmoi() {
  log "Initializing chezmoi with dotfiles repository"

  local chezmoi_bin="$USER_BIN/chezmoi"
  if [[ ! -x "$chezmoi_bin" ]]; then
    abort "chezmoi not found at $chezmoi_bin"
  fi

  if ! "$chezmoi_bin" init "$chezmoi_url"; then
    abort "Failed to initialize chezmoi with $chezmoi_url"
  fi

  info "chezmoi initialized successfully"

  # Run bootstrap script
  local bootstrap_script="$HOME/.local/share/chezmoi/scripts/bootstrap.sh"
  if [[ -x "$bootstrap_script" ]]; then
    log "Running bootstrap script"
    if ! "$bootstrap_script"; then
      abort "Failed to run bootstrap script"
    fi
    info "Bootstrap script completed successfully"
  else
    error "Bootstrap script not found or not executable: $bootstrap_script"
  fi

  # Apply dotfiles with force
  log "Applying dotfiles"
  if ! "$chezmoi_bin" apply --force; then
    abort "Failed to apply dotfiles"
  fi
  info "Dotfiles applied successfully"
}

# Print usage information
usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Install dotfiles and required tools.

OPTIONS:
  -h, --help    Show this help message
  -v, --verbose Enable verbose output

DESCRIPTION:
  This script installs the following tools:
  - chezmoi (dotfiles manager)
  - Homebrew (macOS package manager, macOS only)

  After installation, it initializes chezmoi with the dotfiles repository.

EOF
}

# Main installation function
main() {
  local verbose=false

  # Parse command line arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
      usage
      exit 0
      ;;
    -v | --verbose)
      verbose=true
      set -x
      shift
      ;;
    *)
      abort "Unknown option: $1. Use --help for usage information."
      ;;
    esac
  done

  log "Starting dotfiles installation"

  check_required_tools
  get_arch
  get_os
  setup_directories

  install_chezmoi
  install_homebrew

  init_chezmoi

  log "Dotfiles installation completed successfully!"
  info "Tools installed in: $USER_BIN"
  info "Make sure $USER_BIN is in your PATH"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
