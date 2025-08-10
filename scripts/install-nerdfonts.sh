#!/bin/bash

echo "Installing JetBrains Mono Nerd Font..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Install JetBrains Mono Nerd Font
brew install --cask font-jetbrains-mono-nerd-font

if [ $? -eq 0 ]; then
    echo "JetBrains Mono Nerd Font installed successfully!"
else
    echo "Error: Failed to install JetBrains Mono Nerd Font"
    exit 1
fi