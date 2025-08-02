#!/bin/bash

set -euo pipefail

# SDKMAN and Java versions
SDKMAN_VERSION="5.18.2"
JAVA_VERSION="21.0.5-ms"
MAVEN_VERSION="3.9.9"
GRADLE_VERSION="8.10.2"

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
    aarch64|arm64)
      echo "arm64"
      ;;
    *)
      abort "Unsupported architecture: $arch"
      ;;
  esac
}

# Check prerequisites
check_prerequisites() {
  log "Checking prerequisites for SDKMAN"
  
  local missing_deps=()
  
  # Check for required commands
  for cmd in curl zip unzip; do
    if ! command -v "$cmd" &> /dev/null; then
      missing_deps+=("$cmd")
    fi
  done
  
  if [ ${#missing_deps[@]} -gt 0 ]; then
    log "Missing dependencies: ${missing_deps[*]}"
    
    # Try to install missing dependencies
    if command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install -y "${missing_deps[@]}"
    elif command -v dnf &> /dev/null; then
      sudo dnf install -y "${missing_deps[@]}"
    elif command -v pacman &> /dev/null; then
      sudo pacman -S --needed --noconfirm "${missing_deps[@]}"
    elif command -v brew &> /dev/null; then
      brew install "${missing_deps[@]}"
    else
      abort "Cannot install missing dependencies: ${missing_deps[*]}"
    fi
  fi
}

install_sdkman() {
  log "Installing SDKMAN"
  
  if [ -d "$HOME/.sdkman" ]; then
    log "SDKMAN already installed at $HOME/.sdkman"
    return
  fi
  
  # Download and install SDKMAN
  curl -s "https://get.sdkman.io?rcupdate=false" | bash
  
  # Source SDKMAN for current session
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
}

configure_sdkman() {
  log "Configuring SDKMAN"
  
  # Ensure SDKMAN is sourced
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  
  # Update SDKMAN
  sdk selfupdate force || true
  
  # Configure SDKMAN settings
  if [ -f "$SDKMAN_DIR/etc/config" ]; then
    # Enable auto-answer for prompts
    sed -i.bak 's/sdkman_auto_answer=false/sdkman_auto_answer=true/g' "$SDKMAN_DIR/etc/config" || true
  fi
}

install_java() {
  log "Installing Java $JAVA_VERSION"
  
  # List available Java versions for reference
  echo "Available Java distributions:"
  sdk list java | head -20
  
  # Install Microsoft OpenJDK
  sdk install java "$JAVA_VERSION" || {
    log "Failed to install Java $JAVA_VERSION, trying latest Microsoft Java"
    local latest_ms=$(sdk list java | grep -E "21\.[0-9]+\.[0-9]+-ms" | head -1 | awk '{print $NF}')
    if [ -n "$latest_ms" ]; then
      sdk install java "$latest_ms"
    else
      log "Installing default Java 21"
      sdk install java 21-open
    fi
  }
  
  # Set as default
  sdk default java
  
  # Verify installation
  java -version || abort "Java installation failed"
}

install_build_tools() {
  log "Installing build tools"
  
  # Install Maven
  log "Installing Maven $MAVEN_VERSION"
  sdk install maven "$MAVEN_VERSION" || sdk install maven
  
  # Install Gradle
  log "Installing Gradle $GRADLE_VERSION"
  sdk install gradle "$GRADLE_VERSION" || sdk install gradle
  
  # Verify installations
  mvn -version || echo "Warning: Maven installation verification failed"
  gradle -version || echo "Warning: Gradle installation verification failed"
}

setup_shell_integration() {
  log "Setting up shell integration"
  
  local shells=("$HOME/.bashrc" "$HOME/.zshrc")
  local sdkman_init='[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"'
  
  for shell_rc in "${shells[@]}"; do
    if [ -f "$shell_rc" ]; then
      if ! grep -q "sdkman-init.sh" "$shell_rc"; then
        echo "" >> "$shell_rc"
        echo "# SDKMAN" >> "$shell_rc"
        echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> "$shell_rc"
        echo "$sdkman_init" >> "$shell_rc"
        log "Added SDKMAN configuration to $shell_rc"
      fi
    fi
  done
}

main() {
  local os=$(detect_os)
  local arch=$(detect_arch)
  
  log "Detected: OS=$os, Architecture=$arch"
  
  # Check and install prerequisites
  check_prerequisites
  
  # Install SDKMAN
  install_sdkman
  
  # Configure SDKMAN
  configure_sdkman
  
  # Install Java
  install_java
  
  # Install build tools
  install_build_tools
  
  # Setup shell integration
  setup_shell_integration
  
  log "SDKMAN installation completed!"
  echo ""
  echo "Installed components:"
  echo "===================="
  sdk current
  echo ""
  echo "Please restart your shell or run:"
  echo '  source "$HOME/.sdkman/bin/sdkman-init.sh"'
}

main "$@"