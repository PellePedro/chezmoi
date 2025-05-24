!/bin/bash
set -e

# Install age if missing
if ! command -v age >/dev/null 2>&1; then
  echo "Installing age..."
  if [ -f /etc/arch-release ]; then
    sudo pacman -Sy --noconfirm age
  elif [ -f /etc/debian_version ]; then
    sudo apt update && sudo apt install -y age
  else
    echo "Please install 'age' manually for your distribution."
    exit 1
  fi
fi

# Check if key.txt exists
if [ ! -f "$HOME/.age/key.txt" ]; then
  echo "Missing key.txt! Please copy your age private key to \$HOME/key.txt"
  exit 1
fi

# Decrypt SSH private key if needed
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
  mkdir -p "$HOME/.ssh"
  age --identity "$HOME/key.txt" --decrypt --output "$HOME/.ssh/id_rsa" "{{ .chezmoi.sourceDir }}/ssh/id_rsa.age"
  chmod 600 "$HOME/.ssh/id_rsa"
  echo "Decrypted SSH private key."
fi

# Decrypt API config if needed
if [ ! -f "$HOME/.config/myapp/config.yaml" ]; then
  mkdir -p "$HOME/.config/myapp"
  age --identity "$HOME/key.txt" --decrypt --output "$HOME/.config/myapp/config.yaml" "{{ .chezmoi.sourceDir }}/config/myapp/config.yaml.age"
  chmod 600 "$HOME/.config/myapp/config.yaml"
  echo "Decrypted API config."
fi

echo "Setup complete!"

