#!/bin/bash

set -euo pipefail

GO_VERSION="1.24.7"
GOPLS_VERSION="latest"
STATIC_CHECK_VERSION="2025.1.1"
GOLANGCI_VERSION="v2.5.0"
DELVE_VERSION="latest"

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
    echo "amd64"
    ;;
  aarch64 | arm64)
    echo "arm64"
    ;;
  *)
    abort "Unsupported architecture: $arch"
    ;;
  esac
}

# Detect Linux distribution
detect_distro() {
  if [[ "$OSTYPE" =~ "darwin" ]]; then
    echo "darwin"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
    ubuntu | debian)
      echo "ubuntu"
      ;;
    fedora | rhel | centos | rocky | almalinux)
      echo "fedora"
      ;;
    arch | manjaro)
      echo "arch"
      ;;
    *)
      echo "unknown"
      ;;
    esac
  else
    echo "unknown"
  fi
}

install_go() {
  local os="$1"
  local arch="$2"

  log "Installing Go $GO_VERSION for $os/$arch"

  local golang_tar="${os}-${arch}.tar.gz"
  local golang_url="https://dl.google.com/go/go${GO_VERSION}.${golang_tar}"

  # Remove existing Go installation
  if [ -L "/usr/local/bin/go" ]; then
    sudo rm "/usr/local/bin/go"
  fi

  if [ -d "/usr/local/go" ]; then
    sudo rm -rf "/usr/local/go"
  fi

  # Download and install Go
  curl -fsSL "$golang_url" -o golang.tar.gz || abort "Failed to download Go"
  sudo tar -C /usr/local -xzf golang.tar.gz
  rm golang.tar.gz

  # Create symlink
  sudo ln -sf /usr/local/go/bin/go /usr/local/bin/go
  sudo ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

  # Add to PATH for current session
  export PATH="/usr/local/go/bin:$PATH"

  # Verify installation
  go version || abort "Go installation failed"
}

install_go_tools() {
  log "Installing Go development tools"

  # Ensure GOPATH bin is in PATH
  export PATH="${PATH}:${HOME}/go/bin"

  # Core development tools
  go install golang.org/x/tools/gopls@${GOPLS_VERSION}
  go install github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION}
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@${GOLANGCI_VERSION}
  go install honnef.co/go/tools/cmd/staticcheck@${STATIC_CHECK_VERSION}

  # Additional useful tools
  go install github.com/fatih/gomodifytags@latest
  go install github.com/josharian/impl@latest
  go install github.com/cweill/gotests/gotests@latest
  go install github.com/koron/iferr@latest
  go install golang.org/x/tools/cmd/goimports@latest
  go install golang.org/x/tools/cmd/gorename@latest
  go install github.com/jesseduffield/lazygit@latest

  # Verify installations
  log "Verifying Go tools installation"
  local tools=("gopls" "dlv" "golangci-lint" "staticcheck" "gomodifytags" "impl" "gotests" "iferr" "goimports" "gorename" "lazygit")

  for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
      echo "✓ $tool installed"
    else
      echo "✗ $tool not found in PATH"
    fi
  done
}

main() {
  local os=$(detect_os)
  local arch=$(detect_arch)
  local distro=$(detect_distro)

  log "Detected: OS=$os, Architecture=$arch, Distribution=$distro"

  # Install Go
  install_go "$os" "$arch"

  # Install Go tools
  install_go_tools

  log "Go installation completed!"
  echo "Please add the following to your shell configuration:"
  echo 'export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"'
}

main "$@"

