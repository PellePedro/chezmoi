#!/usr/bin/env bash

set -eu pipefail

# https://github.com/Allaman/dots
# https://github.com/kwanpham2195/dots
# https://github.com/gbprod/yanky.nvim/blob/main/lua/yanky/storage/sqlite.lua

CHEZMOI_VERSION=v2.24.0
AGE_VERSION=v1.2.1
GOPASS_VERSION=1.15.16
OS=""
ARCH="amd64"
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
  arch=$(uname -m)
  if [[ $arch =~ "arm" || $arch =~ "aarch" ]]; then
    ARCH="arm64"
  fi
}

get_os() {
  if [[ "$OSTYPE" =~ "darwin"* ]]; then
    OS="darwin"
    log "Running on Darwin"
  elif [[ "$OSTYPE" =~ "linux" || "$OSTYPE" == "linux-gnu" ]]; then
    OS="linux"
    log "Running on Linux"
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
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
  curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$HOME/.local/bin" sh
  uv venv --python 3.12 $HOME/.local/share/venv
  source $HOME/.local/share/venv/bin/activate
  uv pip install pyvim
}

run_chezmoi() {
  log "Running chezmoi"
  chezmoi init -y git@github.com:pellpedro/chezmoi.git
}

main() {
  for program in wget gunzip tar command chmod rm printf mv mkdir; do
    command -v "$program" >/dev/null 2>&1 || {
      echo "Not found: $program"
      exit 1
    }
  done
  get_arch
  get_os
  get_age
  get_chezmoi
  get_gopass
  install_uv
  # get_homebrew
  # run_chezmoi
  log "Dotfiles configured!"
}

main
