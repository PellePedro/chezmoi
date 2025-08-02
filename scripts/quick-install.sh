#!/bin/sh
# Quick installer that downloads and runs the full bootstrap
# Usage: curl -fsSL https://raw.githubusercontent.com/pellpedro/chezmoi/main/scripts/quick-install.sh | sh

set -eu

REPO_URL="git@github.com:pellpedro/chezmoi.git"
INSTALL_DIR="$HOME/.chezmoi-bootstrap"

printf "[INFO] Downloading chezmoi bootstrap scripts...\n"

# Check for git
if ! command -v git >/dev/null 2>&1; then
    printf "[ERROR] git is not installed. Please install git first.\n" >&2
    printf "  Ubuntu/Debian: sudo apt-get install git\n" >&2
    printf "  Fedora/RHEL:   sudo dnf install git\n" >&2
    printf "  Arch:          sudo pacman -S git\n" >&2
    printf "  macOS:         xcode-select --install\n" >&2
    exit 1
fi

# Try SSH first, fall back to HTTPS if it fails
printf "[INFO] Testing repository access...\n"
CLONE_URL="$REPO_URL"

# Test SSH access (works with ssh-agent)
if git ls-remote "$CLONE_URL" >/dev/null 2>&1; then
    printf "[INFO] SSH access confirmed, using SSH URL\n"
else
    printf "[INFO] SSH access failed, trying HTTPS...\n"
    CLONE_URL="https://github.com/pellpedro/chezmoi.git"
fi

# Clone the repository
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
fi

git clone --depth 1 "$CLONE_URL" "$INSTALL_DIR" || {
    printf "[ERROR] Failed to clone repository\n" >&2
    printf "[ERROR] If this is a private repository, you need to:\n" >&2
    printf "[ERROR] 1. Set up SSH keys: ssh-keygen -t ed25519 -C 'your-email@example.com'\n" >&2
    printf "[ERROR] 2. Add the key to GitHub: https://github.com/settings/keys\n" >&2
    exit 1
}

# Run the bootstrap script
printf "[INFO] Running bootstrap script...\n"
cd "$INSTALL_DIR/scripts" || exit 1
chmod +x *.sh

# Run with all components by default, or pass arguments
if [ $# -eq 0 ]; then
    exec ./bootstrap.sh core packages
else
    exec ./bootstrap.sh "$@"
fi