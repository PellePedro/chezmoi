#!/bin/bash
set -e

bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)

curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

curl -LsSf https://astral.sh/uv/install.sh | sh
