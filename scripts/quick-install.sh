#!/bin/bash
# Quick installer that downloads and runs the full bootstrap
# Usage: curl -fsSL https://raw.githubusercontent.com/PellPedro/chezmoi/main/scripts/quick-install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/PellPedro/chezmoi.git"
INSTALL_DIR="$HOME/.chezmoi-bootstrap"

echo "[INFO] Downloading chezmoi bootstrap scripts..."

# Clone the repository
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
fi

git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"

# Run the bootstrap script
echo "[INFO] Running bootstrap script..."
cd "$INSTALL_DIR/scripts"
chmod +x *.sh

# Run with all components by default, or pass arguments
if [ $# -eq 0 ]; then
    ./bootstrap.sh core packages
else
    ./bootstrap.sh "$@"
fi

# Cleanup
cd ~
rm -rf "$INSTALL_DIR"

echo "[INFO] Bootstrap completed!"