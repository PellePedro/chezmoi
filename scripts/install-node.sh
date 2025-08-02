#!/bin/bash

set -euo pipefail

NODE_VERSION="v24.4.0"
FNM_VERSION="v1.38.1"

# Logging function
log() {
  printf "################################################################################\n"
  printf "%s\n" "$@"
  printf "################################################################################\n"
}

abort() {
  printf "ERROR: %s\n" "$@" >&2
  exit 1
}

# Detect OS
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "darwin"
  else
    abort "Unsupported OS: $OSTYPE"
  fi
}

# Detect architecture
detect_arch() {
  local arch=$(uname -m)
  case "$arch" in
    x86_64)
      echo "x64"
      ;;
    aarch64)
      echo "arm64"
      ;;
    arm64)
      if [[ "$(detect_os)" == "darwin" ]]; then
        echo "arm64"
      else
        echo "arm64"
      fi
      ;;
    *)
      abort "Unsupported architecture: $arch"
      ;;
  esac
}

install_fnm() {
  log "Installing Fast Node Manager (fnm)"
  
  if ! command -v fnm &> /dev/null; then
    # Install fnm
    curl -fsSL https://fnm.vercel.app/install | bash
    
    # Source fnm for current session
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
  else
    log "fnm already installed"
  fi
}

install_node() {
  log "Installing Node.js $NODE_VERSION"
  
  # Ensure fnm is available
  if ! command -v fnm &> /dev/null; then
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
  fi
  
  # Install Node.js
  fnm install "$NODE_VERSION"
  fnm use "$NODE_VERSION"
  fnm default "$NODE_VERSION"
  
  # Verify installation
  node --version || abort "Node.js installation failed"
  npm --version || abort "npm not found"
}

install_global_packages() {
  log "Installing global npm packages"
  
  # Essential development tools
  local packages=(
    "@anthropic-ai/claude-code"
    "typescript"
    "tsx"
    "prettier"
    "eslint"
    "npm-check-updates"
    "yarn"
    "pnpm"
  )
  
  for package in "${packages[@]}"; do
    echo "Installing $package..."
    npm install -g "$package" || echo "Warning: Failed to install $package"
  done
  
  # Verify installations
  log "Verifying npm packages"
  echo "Node.js: $(node --version)"
  echo "npm: $(npm --version)"
  
  # Check Claude Code specifically
  if command -v claude &> /dev/null; then
    echo "✓ Claude Code installed"
  else
    echo "✗ Claude Code not found in PATH"
  fi
}

setup_shell_integration() {
  log "Setting up shell integration"
  
  local shell_config=""
  
  # Detect shell configuration file
  if [ -n "${ZSH_VERSION:-}" ] || [ -f "$HOME/.zshrc" ]; then
    shell_config="$HOME/.zshrc"
  elif [ -n "${BASH_VERSION:-}" ] || [ -f "$HOME/.bashrc" ]; then
    shell_config="$HOME/.bashrc"
  fi
  
  if [ -n "$shell_config" ]; then
    # Check if fnm is already configured
    if ! grep -q "fnm env" "$shell_config" 2>/dev/null; then
      echo "" >> "$shell_config"
      echo "# fnm (Fast Node Manager)" >> "$shell_config"
      echo 'export PATH="$HOME/.local/share/fnm:$PATH"' >> "$shell_config"
      echo 'eval "$(fnm env --use-on-cd)"' >> "$shell_config"
      log "Added fnm configuration to $shell_config"
    else
      log "fnm already configured in $shell_config"
    fi
  fi
}

main() {
  local os=$(detect_os)
  local arch=$(detect_arch)
  
  log "Detected: OS=$os, Architecture=$arch"
  
  # Install fnm
  install_fnm
  
  # Install Node.js
  install_node
  
  # Install global packages
  install_global_packages
  
  # Setup shell integration
  setup_shell_integration
  
  log "Node.js installation completed!"
  echo ""
  echo "Please restart your shell or run:"
  echo '  export PATH="$HOME/.local/share/fnm:$PATH"'
  echo '  eval "$(fnm env --use-on-cd)"'
}

main "$@"