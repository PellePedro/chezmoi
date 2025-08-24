#!/bin/bash

set -euo pipefail

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

# Common packages across all distributions
COMMON_PACKAGES=(
  "curl"
  "wget"
  "git"
  "jq"
  "netcat"
  "socat"
  "ripgrep"
  "zsh"
  "tmux"
  "htop"
  "tree"
)

# Development packages
DEV_PACKAGES=(
  "build-essential|base-devel|gcc gcc-c++ make|gcc gcc-c++ make"
  "protobuf-compiler|protobuf|protobuf|protobuf-compiler"
  "cmake|cmake|cmake|cmake"
  "pkg-config|pkgconf|pkg-config|pkgconfig"
  "sqlite3|sqlite|sqlite3|sqlite"
)

# Network tools
NET_PACKAGES=(
  "net-tools|net-tools|net-tools|net-tools"
  "dnsutils|bind-tools|bind-utils|bind"
  "iputils-ping|iputils|iputils|iputils"
  "iproute2|iproute2|iproute|iproute2"
  "nmap|nmap|nmap|nmap"
)

install_apt_packages() {
  log "Installing packages with apt"

  # Update package list
  sudo apt-get update

  # Install common packages
  local packages=()
  packages+=(${COMMON_PACKAGES[@]})
  packages+=("nnn")
  packages+=("fd-find")
  packages+=("bat")

  # Add Ubuntu/Debian specific packages
  for pkg_set in "${DEV_PACKAGES[@]}" "${NET_PACKAGES[@]}"; do
    IFS='|' read -ra VARIANTS <<<"$pkg_set"
    packages+=("${VARIANTS[0]}")
  done

  # Install all packages
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}" || {
    log "Some packages failed to install, continuing..."
  }

  # Create symlinks for differently named packages
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
  fi
  if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    sudo ln -sf "$(which batcat)" /usr/local/bin/bat
  fi
}

install_dnf_packages() {
  log "Installing packages with dnf"

  # Install common packages
  local packages=()
  packages+=(${COMMON_PACKAGES[@]})
  packages+=("nnn")
  packages+=("fd-find")
  packages+=("bat")
  packages+=("util-linux-user") # for chsh

  # Add Fedora specific packages
  for pkg_set in "${DEV_PACKAGES[@]}" "${NET_PACKAGES[@]}"; do
    IFS='|' read -ra VARIANTS <<<"$pkg_set"
    packages+=("${VARIANTS[2]}")
  done

  # Enable EPEL for some packages on RHEL-based systems
  if [[ -f /etc/redhat-release ]]; then
    sudo dnf install -y epel-release || true
  fi

  # Install all packages
  sudo dnf install -y "${packages[@]}" || {
    log "Some packages failed to install, continuing..."
  }
}

install_pacman_packages() {
  log "Installing packages with pacman"

  # Update package database
  sudo pacman -Sy

  # Install common packages
  local packages=()
  packages+=(${COMMON_PACKAGES[@]})
  packages+=("nnn")
  packages+=("fd")
  packages+=("bat")

  # Add Arch specific packages
  for pkg_set in "${DEV_PACKAGES[@]}" "${NET_PACKAGES[@]}"; do
    IFS='|' read -ra VARIANTS <<<"$pkg_set"
    packages+=("${VARIANTS[1]}")
  done

  # Install all packages
  sudo pacman -S --needed --noconfirm "${packages[@]}" || {
    log "Some packages failed to install, continuing..."
  }
}

install_brew_packages() {
  log "Installing additional packages with Homebrew"

  # Ensure Homebrew is installed
  if ! command -v brew &>/dev/null; then
    log "Homebrew not found. Please install it first using install-core.sh"
    return
  fi

  # Homebrew packages for better cross-platform tools
  local brew_packages=(
    "fzf"
    "eza"
    "dust"
    "git-delta"
    "gh"
    "lazygit"
    "k9s"
    "just"
    "zoxide"
    "atuin"
    "shellcheck"
    "shfmt"
    "yq"
    "watch"
    "pspg"
    "zellij"
    "ngrep"
  )

  for pkg in "${brew_packages[@]}"; do
    if ! brew list "$pkg" &>/dev/null; then
      log "Installing $pkg via Homebrew"
      brew install "$pkg" || echo "Warning: Failed to install $pkg"
    fi
  done

  # Install fonts on macOS
  if [[ "$(detect_distro)" == "darwin" ]]; then
    brew tap homebrew/cask-fonts || true
    brew install --cask font-hack-nerd-font || true
    brew install --cask wezterm || true
    brew install sst/tap/opencode || true
  fi
}

setup_shell() {
  log "Setting up shell configuration"

  # Install Oh My Zsh if not present
  if [ ! -d "$HOME/.oh-my-zsh" ] && command -v zsh &>/dev/null; then
    log "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
  fi

  # Change default shell to zsh if available
  if command -v zsh &>/dev/null && [ "$SHELL" != "$(which zsh)" ]; then
    log "Changing default shell to zsh"
    sudo chsh -s "$(which zsh)" "$USER" || true
  fi
}

main() {
  local distro=$(detect_distro)

  log "Detected distribution: $distro"

  # Install native packages based on distribution
  case "$distro" in
  ubuntu)
    install_apt_packages
    ;;
  fedora)
    install_dnf_packages
    ;;
  arch)
    install_pacman_packages
    ;;
  darwin)
    log "macOS detected, skipping native package installation"
    ;;
  *)
    abort "Unsupported distribution: $distro"
    ;;
  esac

  # Install Homebrew packages (cross-platform tools)
  install_brew_packages

  # Setup shell
  setup_shell

  log "Package installation completed!"

  # Print installed tools summary
  echo ""
  echo "Installed tools summary:"
  echo "========================"

  local tools=("git" "curl" "wget" "jq" "ripgrep" "fd" "bat" "fzf" "eza" "zsh")
  for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
      echo "✓ $tool"
    else
      echo "✗ $tool not found"
    fi
  done
}

main "$@"
