# Chezmoi Bootstrap Scripts

This directory contains installation scripts for setting up a development environment before applying chezmoi dotfiles.

## Supported Platforms

- **Operating Systems**: Darwin (macOS), Ubuntu/Debian, Fedora/RHEL, Arch Linux
- **Architectures**: amd64 (x86_64), arm64 (aarch64)

## Scripts Overview

### bootstrap.sh
Main entry point that orchestrates the installation process. Run this script to select and install components interactively or specify components as arguments.

```bash
# Interactive mode
./bootstrap.sh

# Install specific components
./bootstrap.sh core packages go node java neovim

# Install everything
./bootstrap.sh core packages go node java neovim

# Build Neovim with custom options
./scripts/install-neovim.sh --branch release-0.10 --prefix /usr/local
```

### install-core.sh
Installs essential tools needed for chezmoi and basic development:
- **chezmoi**: Dotfile management
- **age**: Encryption tool
- **gopass**: Password manager
- **Homebrew**: Package manager (on all platforms)
- **uv**: Fast Python package installer
- **Atuin**: Shell history sync and search
- **Rust**: Rust programming language and cargo
- **Zoxide**: Smarter cd command

### install-packages.sh
Installs system packages using a hybrid approach:
- **Native package managers** for system-level tools
- **Homebrew** for modern developer tools
- Includes: git, ripgrep, fzf, eza, bat, zsh, and more

### install-go.sh
Installs Go programming language and development tools:
- Downloads and installs Go directly from official sources
- Installs Go tools: gopls, golangci-lint, delve, etc.

### install-node.sh
Installs Node.js environment:
- **fnm**: Fast Node Manager for version management
- Node.js and npm
- Global packages: TypeScript, Claude Code, prettier, etc.

### install-sdkman.sh
Installs Java development environment:
- **SDKMAN**: SDK version manager
- Java (Microsoft OpenJDK 21)
- Maven and Gradle build tools

### install-neovim.sh
Builds Neovim from source:
- Installs all build dependencies for each platform
- Clones and builds Neovim from the master branch (configurable)
- Installs Lua dependencies via luarocks
- Sets up runtime dependencies (ripgrep, fd, tree-sitter-cli)
- Supports custom branch, prefix, and build directory options

## Package Management Strategy

The scripts use a **hybrid approach**:

1. **Native Package Managers** (apt, dnf, pacman) for:
   - System libraries and build tools
   - Network utilities
   - Tools tightly integrated with the OS

2. **Homebrew** for:
   - Modern developer tools
   - Cross-platform consistency
   - Tools not available in native repositories

## Usage

1. Clone the chezmoi repository:
   ```bash
   git clone git@github.com:yourusername/chezmoi.git
   cd chezmoi/scripts
   ```

2. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```

3. Run the bootstrap script:
   ```bash
   ./bootstrap.sh
   ```

4. After installation, restart your shell and initialize chezmoi:
   ```bash
   chezmoi init
   chezmoi apply
   ```

## Notes

- Scripts require sudo access for system package installation
- Do not run the scripts with sudo directly
- Scripts are idempotent - safe to run multiple times
- Each script can be run independently if needed