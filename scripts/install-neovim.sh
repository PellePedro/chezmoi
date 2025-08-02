#!/bin/bash

set -euo pipefail

# Neovim build configuration
NVIM_RELEASE="${NVIM_RELEASE:-master}"
BUILD_DIR="${BUILD_DIR:-/tmp/neovim-build}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/usr/local}"

# Logging functions
log() {
  printf "################################################################################\n"
  printf "%s\n" "$@"
  printf "################################################################################\n"
}

abort() {
  printf "ERROR: %s\n" "$@" >&2
  exit 1
}

# Detect Linux distribution
detect_distro() {
  if [[ "$OSTYPE" =~ "darwin" ]]; then
    echo "darwin"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu|debian)
        echo "debian"
        ;;
      fedora|rhel|centos|rocky|almalinux)
        echo "fedora"
        ;;
      arch|manjaro)
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

install_debian_deps() {
  log "Installing Debian/Ubuntu build dependencies"
  
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-transport-https \
    autoconf \
    automake \
    clang \
    cmake \
    curl \
    doxygen \
    g++ \
    gettext \
    git \
    gperf \
    libluajit-5.1-dev \
    libmsgpack-dev \
    libtermkey-dev \
    libtool \
    libtool-bin \
    libunibilium-dev \
    libutf8proc-dev \
    libuv1-dev \
    libvterm-dev \
    luajit \
    luarocks \
    make \
    ninja-build \
    pkg-config \
    unzip \
    ca-certificates
}

install_fedora_deps() {
  log "Installing Fedora/RHEL build dependencies"
  
  sudo dnf groupinstall -y "Development Tools"
  sudo dnf install -y \
    cmake \
    gcc-c++ \
    libtool \
    libuv-devel \
    libvterm-devel \
    luajit-devel \
    msgpack-devel \
    unibilium-devel \
    libtermkey-devel \
    libmpack-devel \
    tree-sitter-devel \
    gettext \
    ninja-build
}

install_arch_deps() {
  log "Installing Arch Linux build dependencies"
  
  sudo pacman -Sy --needed --noconfirm \
    base-devel \
    cmake \
    unzip \
    ninja \
    curl \
    libuv \
    msgpack-c \
    libtermkey \
    unibilium \
    libvterm \
    luajit \
    lua51-lpeg \
    lua51-mpack \
    tree-sitter \
    gettext
}

install_darwin_deps() {
  log "Installing macOS build dependencies"
  
  # Ensure Xcode Command Line Tools are installed
  if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Xcode Command Line Tools"
    xcode-select --install
    
    # Wait for installation to complete
    echo "Press any key when Xcode Command Line Tools installation is complete..."
    read -n 1 -s
  fi
  
  # Install dependencies via Homebrew
  if ! command -v brew >/dev/null 2>&1; then
    abort "Homebrew is required. Please install it first using install-core.sh"
  fi
  
  log "Installing dependencies via Homebrew"
  brew install \
    ninja \
    cmake \
    pkg-config \
    gettext \
    curl \
    libuv \
    luajit \
    msgpack \
    libtermkey \
    unibilium \
    libvterm \
    tree-sitter \
    luarocks
}

install_lua_dependencies() {
  log "Installing Lua dependencies"
  
  # Install with luarocks
  if command -v luarocks >/dev/null 2>&1; then
    sudo luarocks install mpack || true
    sudo luarocks install lpeg || true
    sudo luarocks install inspect || true
  else
    log "Luarocks not found, skipping Lua dependencies"
  fi
}

clone_neovim() {
  log "Cloning Neovim repository (branch: $NVIM_RELEASE)"
  
  # Clean up any existing build directory
  if [ -d "$BUILD_DIR" ]; then
    log "Removing existing build directory"
    rm -rf "$BUILD_DIR"
  fi
  
  # Clone repository
  git clone https://github.com/neovim/neovim.git --branch "$NVIM_RELEASE" --depth 1 "$BUILD_DIR"
  cd "$BUILD_DIR"
}

build_neovim() {
  log "Building Neovim"
  
  cd "$BUILD_DIR"
  
  # Set build configuration
  export CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-RelWithDebInfo}"
  export CMAKE_EXTRA_FLAGS="${CMAKE_EXTRA_FLAGS:--DENABLE_JEMALLOC=OFF}"
  
  # Build with make
  make CMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
       CMAKE_EXTRA_FLAGS="$CMAKE_EXTRA_FLAGS" \
       CMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
}

install_neovim() {
  log "Installing Neovim to $INSTALL_PREFIX"
  
  cd "$BUILD_DIR"
  sudo make install
  
  # Verify installation
  if command -v nvim >/dev/null 2>&1; then
    log "Neovim installed successfully!"
    nvim --version
  else
    abort "Neovim installation failed"
  fi
}

cleanup() {
  log "Cleaning up build directory"
  rm -rf "$BUILD_DIR"
}

setup_runtime_deps() {
  log "Setting up runtime dependencies"
  
  # Install common runtime dependencies
  local deps=("ripgrep" "fd" "tree-sitter-cli")
  
  if command -v brew >/dev/null 2>&1; then
    for dep in "${deps[@]}"; do
      brew list "$dep" &>/dev/null || brew install "$dep"
    done
  elif command -v cargo >/dev/null 2>&1; then
    # Install via cargo if available
    cargo install ripgrep fd-find tree-sitter-cli
  fi
  
  # Install Python provider
  if command -v pip3 >/dev/null 2>&1; then
    pip3 install --user pynvim || true
  fi
  
  # Install Node provider
  if command -v npm >/dev/null 2>&1; then
    npm install -g neovim || true
  fi
}

main() {
  local distro=$(detect_distro)
  
  log "Detected distribution: $distro"
  log "Neovim branch: $NVIM_RELEASE"
  log "Install prefix: $INSTALL_PREFIX"
  
  # Check if Neovim is already installed
  if command -v nvim >/dev/null 2>&1; then
    local current_version=$(nvim --version | head -1)
    log "Current Neovim: $current_version"
    read -p "Neovim is already installed. Continue with build? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log "Build cancelled"
      exit 0
    fi
  fi
  
  # Install build dependencies based on distribution
  case "$distro" in
    debian)
      install_debian_deps
      ;;
    fedora)
      install_fedora_deps
      ;;
    arch)
      install_arch_deps
      ;;
    darwin)
      install_darwin_deps
      ;;
    *)
      abort "Unsupported distribution: $distro"
      ;;
  esac
  
  # Install Lua dependencies
  install_lua_dependencies
  
  # Clone Neovim
  clone_neovim
  
  # Build Neovim
  build_neovim
  
  # Install Neovim
  install_neovim
  
  # Setup runtime dependencies
  setup_runtime_deps
  
  # Cleanup
  read -p "Remove build directory? [Y/n] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    cleanup
  fi
  
  log "Neovim build completed!"
  echo ""
  echo "To use Neovim, make sure $INSTALL_PREFIX/bin is in your PATH"
  echo "You may want to set up your Neovim configuration next"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --branch)
      NVIM_RELEASE="$2"
      shift 2
      ;;
    --prefix)
      INSTALL_PREFIX="$2"
      shift 2
      ;;
    --build-dir)
      BUILD_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--branch BRANCH] [--prefix PREFIX] [--build-dir DIR]"
      exit 1
      ;;
  esac
done

main "$@"