#!/bin/bash

set -e

GO_VERSION="1.23.4"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
  ARCH="arm64"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

GOLANG_TAR="linux-${ARCH}.tar.gz"
GOLANG_DOWNLOAD_URL="https://dl.google.com/go/go${GO_VERSION}.${GOLANG_TAR}"

echo "Downloading Go $GO_VERSION for $ARCH..."
curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz

echo "Installing Go..."
sudo tar -C /usr/local -xzf golang.tar.gz
rm golang.tar.gz
sudo ln -sf /usr/local/go/bin/* /usr/local/bin
echo "Go $GO_VERSION installed successfully."

# Cleanup
rm -rf "${GOLANG_TAR}"
