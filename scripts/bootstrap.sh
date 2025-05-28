#!/bin/bash

packages=(
  "chezmoi"
  "gopass"
  "age"
)

install_uv() {
  log "Installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$HOME/.local/bin" sh
  mkdir -p $HOME/.local/share
  uv venv --python 3.12 $HOME/.local/share/venv
  source $HOME/.local/share/venv/bin/activate
  uv pip install pyvim
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install packages
for package in "${packages[@]}"; do
    if ! brew list "$package" &> /dev/null; then
        echo "Installing $package..."
        brew install "$package"
    else
        echo "$package is already installed"
    fi
done

install_uv