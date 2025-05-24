#!/usr/bin/env bash
set -euo pipefail

# Set install location
HOMEBREW_DIR="$HOME/.local/share/homebrew"

# Create install directory
mkdir -p "$HOMEBREW_DIR"

# Download and extract Homebrew
echo "Installing Homebrew to $HOMEBREW_DIR..."
curl -L https://github.com/Homebrew/brew/tarball/master | tar -xz --strip-components=1 -C "$HOMEBREW_DIR"

# Export shell environment for Homebrew
echo "Configuring Homebrew shell environment..."
eval "$("$HOMEBREW_DIR/bin/brew" shellenv)"

# Update Homebrew quietly
brew update --force --quiet

# Secure Zsh share directory
ZSH_DIR="$(brew --prefix)/share/zsh"
if [ -d "$ZSH_DIR" ]; then
  echo "Hardening permissions on $ZSH_DIR..."
  chmod -R go-w "$ZSH_DIR"
fi

echo "✅ Homebrew installed and configured in $HOMEBREW_DIR"
