#!/bin/bash

set -e

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker ${USER}

sudo systemctl enable docker

curl --fail -sL https://api.github.com/repos/docker/compose/releases/latest| grep tag_name | cut -d '"' -f 4 | tee /tmp/compose-version
sudo mkdir -p /usr/lib/docker/cli-plugins
sudo  curl --fail -sL -o /usr/lib/docker/cli-plugins/docker-compose https://github.com/docker/compose/releases/download/$(cat /tmp/compose-version)/docker-compose-$(uname -s)-$(uname -m)
sudo chmod +x /usr/lib/docker/cli-plugins/docker-compose
sudo ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose
rm /tmp/compose-version

