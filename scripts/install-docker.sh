#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        print_message "$RED" "Cannot detect OS. /etc/os-release not found."
        exit 1
    fi
}

# Function to install Docker on Ubuntu
install_docker_ubuntu() {
    print_message "$GREEN" "Installing Docker on Ubuntu..."
    
    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Update package index
    sudo apt-get update
    
    # Install prerequisites
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    sudo apt-get update
    
    # Install Docker Engine and Docker Compose plugin
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    print_message "$GREEN" "Docker installed successfully on Ubuntu!"
}

# Function to install Docker on Debian
install_docker_debian() {
    print_message "$GREEN" "Installing Docker on Debian..."
    
    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Update package index
    sudo apt-get update
    
    # Install prerequisites
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg
    
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    sudo apt-get update
    
    # Install Docker Engine and Docker Compose plugin
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    print_message "$GREEN" "Docker installed successfully on Debian!"
}

# Function to install Docker on Arch Linux
install_docker_arch() {
    print_message "$GREEN" "Installing Docker on Arch Linux..."
    
    # Update system
    sudo pacman -Syu --noconfirm
    
    # Install Docker and Docker Compose plugin
    sudo pacman -S --noconfirm docker docker-compose
    
    # Enable and start Docker service
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    
    print_message "$GREEN" "Docker installed successfully on Arch Linux!"
}

# Function to configure Docker post-installation
configure_docker() {
    print_message "$YELLOW" "Configuring Docker..."
    
    # Create docker group if it doesn't exist
    if ! getent group docker > /dev/null 2>&1; then
        sudo groupadd docker
        print_message "$GREEN" "Created docker group"
    fi
    
    # Add current user to docker group
    if ! groups $USER | grep -q docker; then
        sudo usermod -aG docker $USER
        print_message "$GREEN" "Added $USER to docker group"
        
        # Try to activate the group changes without requiring logout
        if command -v newgrp &> /dev/null; then
            print_message "$YELLOW" "Attempting to activate docker group membership..."
            # Create a flag file to indicate group change was made
            touch ~/.docker-group-added
        fi
    else
        print_message "$GREEN" "User $USER is already in docker group"
    fi
    
    # Start Docker service if not running
    if ! systemctl is-active --quiet docker; then
        sudo systemctl start docker
    fi
    
    # Enable Docker to start on boot
    sudo systemctl enable docker
    
    # Set correct permissions on docker socket
    if [ -e /var/run/docker.sock ]; then
        sudo chown root:docker /var/run/docker.sock
        sudo chmod 660 /var/run/docker.sock
    fi
    
    print_message "$GREEN" "Docker configuration complete!"
}

# Function to verify installation
verify_installation() {
    print_message "$YELLOW" "Verifying Docker installation..."
    
    # Check Docker version
    if command -v docker &> /dev/null; then
        print_message "$GREEN" "Docker version:"
        docker --version
    else
        print_message "$RED" "Docker installation failed!"
        exit 1
    fi
    
    # Check Docker Compose version
    if docker compose version &> /dev/null; then
        print_message "$GREEN" "Docker Compose version:"
        docker compose version
    else
        print_message "$YELLOW" "Docker Compose plugin not found. You may need to restart your shell."
    fi
}

# Main script
main() {
    print_message "$GREEN" "=== Docker Installation Script ==="
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then 
        print_message "$RED" "Please do not run this script as root. It will use sudo when needed."
        exit 1
    fi
    
    # Detect OS
    detect_os
    
    print_message "$YELLOW" "Detected OS: $OS"
    
    # Install Docker based on OS
    case "$OS" in
        ubuntu)
            install_docker_ubuntu
            ;;
        debian)
            install_docker_debian
            ;;
        arch|manjaro|endeavouros)
            install_docker_arch
            ;;
        *)
            print_message "$RED" "Unsupported OS: $OS"
            print_message "$YELLOW" "This script supports Ubuntu, Debian, and Arch Linux only."
            exit 1
            ;;
    esac
    
    # Configure Docker
    configure_docker
    
    # Verify installation
    verify_installation
    
    print_message "$GREEN" "=== Docker installation complete! ==="
    
    # Check if user was added to docker group in this session
    if [ -f ~/.docker-group-added ]; then
        rm ~/.docker-group-added
        print_message "$YELLOW" "IMPORTANT: Your user was added to the docker group."
        print_message "$YELLOW" "To use Docker without sudo, you need to either:"
        print_message "$YELLOW" "  1. Log out and log back in (recommended)"
        print_message "$YELLOW" "  2. Run: newgrp docker (temporary, current shell only)"
        print_message "$YELLOW" "  3. Run: su - $USER (re-login as yourself)"
    else
        print_message "$GREEN" "Your user is already in the docker group."
    fi
    
    print_message "$YELLOW" "Test Docker with: docker run hello-world"
    
    # Try to test if docker works without sudo
    if docker ps &> /dev/null; then
        print_message "$GREEN" "Docker is working without sudo!"
    else
        print_message "$YELLOW" "Docker requires sudo or re-login to work without sudo."
    fi
}

# Run main function
main "$@"