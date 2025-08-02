#!/bin/bash

set -eu pipefail

# https://github.com/Allaman/dots
# https://github.com/kwanpham2195/dots
# https://github.com/gbprod/yanky.nvim/blob/main/lua/yanky/storage/sqlite.lua

CHEZMOI_VERSION=v2.63.1
AGE_VERSION=v1.2.1
GOPASS_VERSION=1.15.16
OS=""
ARCH=""
DISTRO=""
USER_BIN="$HOME/.local/bin"

mkdir -p "$USER_BIN"

abort() {
  printf "ERROR: %s\n" "$@" >&2
  exit 1
}

log() {
  printf "################################################################################\n"
  printf "%s\n" "$@"
  printf "################################################################################\n"
}

get_arch() {
  local arch=$(uname -m)
  case "$arch" in
    x86_64)
      ARCH="amd64"
      ;;
    aarch64|arm64)
      ARCH="arm64"
      ;;
    armv7l|armv8l)
      ARCH="arm"
      ;;
    *)
      abort "Unsupported architecture: $arch"
      ;;
  esac
  log "Detected architecture: $ARCH"
}

get_os() {
  if [[ "$OSTYPE" =~ "darwin"* ]]; then
    OS="darwin"
    DISTRO="darwin"
    log "Running on Darwin"
  elif [[ "$OSTYPE" =~ "linux" || "$OSTYPE" == "linux-gnu" ]]; then
    OS="linux"
    # Detect Linux distribution
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case "$ID" in
        ubuntu|debian)
          DISTRO="ubuntu"
          ;;
        fedora|rhel|centos)
          DISTRO="fedora"
          ;;
        arch|manjaro)
          DISTRO="arch"
          ;;
        *)
          DISTRO="unknown"
          ;;
      esac
    else
      DISTRO="unknown"
    fi
    log "Running on Linux ($DISTRO)"
  else
    abort "Unsupported OS: $OSTYPE"
  fi
}

check_available_tool() {
  command -v "$1" >/dev/null 2>&1 || {
    echo >&2 "require foo"
    exit 1
  }
}

get_chezmoi() {
  log "Get chezmoi"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$USER_BIN"
}

get_homebrew() {
  log "Installing Homebrew"
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Set up Homebrew in PATH
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
  else
    log "Homebrew already installed"
  fi
}

get_age() {
  log "Get age"
  # TODO: gunzip and tar might not be available...
  wget -q https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-${OS}-${ARCH}.tar.gz -O /tmp/age.tar.gz
  gunzip /tmp/age.tar.gz
  tar -xC /tmp -f /tmp/age.tar
  mv /tmp/age/age* "$USER_BIN/"
  chmod +x "$USER_BIN/age"
  chmod +x "$USER_BIN/age-keygen"
  rm -r /tmp/age*
}

get_gopass() {
  log "Get gopass"
  curl -sSL "https://github.com/gopasspw/gopass/releases/download/v${GOPASS_VERSION}/gopass-${GOPASS_VERSION}-${OS}-${ARCH}.tar.gz" | tar -xz -C /tmp
  mv /tmp/gopass "$USER_BIN/"
  chmod +x "$USER_BIN/gopass"
}

install_uv() {
  log "Installing uv"
  if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$HOME/.local/bin" sh
  fi
  
  # Create Python virtual environment
  if [ ! -d "$HOME/.local/share/venv" ]; then
    mkdir -p $HOME/.local/share
    "$USER_BIN/uv" venv --python 3.12 $HOME/.local/share/venv
    . $HOME/.local/share/venv/bin/activate
    "$USER_BIN/uv" pip install pyvim
  else
    log "Python venv already exists"
  fi
}

install_atuin() {
  log "Installing Atuin"
  if ! command -v atuin >/dev/null 2>&1; then
    bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
  else
    log "Atuin already installed"
  fi
}

install_rust() {
  log "Installing Rust"
  if ! command -v rustc >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    
    # Source cargo for current session
    . "$HOME/.cargo/env"
    
    # Verify installation
    rustc --version || log "Rust installation may require shell restart"
  else
    log "Rust already installed"
  fi
}

install_zoxide() {
  log "Installing Zoxide"
  if ! command -v zoxide >/dev/null 2>&1; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    
    # Move zoxide to USER_BIN if it was installed elsewhere
    if [ -f "./zoxide" ]; then
      mv ./zoxide "$USER_BIN/"
      chmod +x "$USER_BIN/zoxide"
    fi
  else
    log "Zoxide already installed"
  fi
}

run_chezmoi() {
  log "Running chezmoi"
  chezmoi init -y git@github.com:pellpedro/chezmoi.git
}

install_base_dependencies() {
  log "Installing base dependencies"
  
  case "$DISTRO" in
    ubuntu)
      sudo apt-get update
      sudo apt-get install -y curl wget gunzip tar git build-essential
      ;;
    fedora)
      sudo dnf install -y curl wget gzip tar git gcc gcc-c++ make
      ;;
    arch)
      sudo pacman -Sy --needed --noconfirm curl wget gzip tar git base-devel
      ;;
    darwin)
      # macOS has most tools pre-installed
      log "Darwin detected, checking for Xcode Command Line Tools"
      if ! xcode-select -p >/dev/null 2>&1; then
        log "Installing Xcode Command Line Tools"
        xcode-select --install
      fi
      ;;
  esac
}

main() {
  get_arch
  get_os
  
  # Install base dependencies first
  install_base_dependencies
  
  # Verify required tools
  for program in wget gunzip tar command chmod rm printf mv mkdir curl; do
    command -v "$program" >/dev/null 2>&1 || {
      abort "Required tool not found: $program"
    }
  done
  
  get_age
  get_chezmoi
  get_gopass
  get_homebrew
  install_uv
  install_atuin
  install_rust
  install_zoxide
  # run_chezmoi
  log "Core tools installation completed!"
}

main
