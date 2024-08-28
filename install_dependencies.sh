#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages for Debian-based systems
install_debian_packages() {
    echo "Installing packages for Debian-based system..."

    sudo apt-get update
    sudo apt-get install -y jq lm-sensors upower net-tools
}

# Function to install packages for Red Hat-based systems
install_redhat_packages() {
    echo "Installing packages for Red Hat-based system..."

    sudo yum install -y jq lm_sensors upower net-tools
}

# Detect the OS and install the appropriate packages
if [ -f /etc/debian_version ]; then
    # Debian-based system
    if ! command_exists jq || ! command_exists sensors || ! command_exists upower || ! command_exists netstat; then
        install_debian_packages
    else
        echo "All required packages are already installed."
    fi
elif [ -f /etc/redhat-release ]; then
    # Red Hat-based system
    if ! command_exists jq || ! command_exists sensors || ! command_exists upower || ! command_exists netstat; then
        install_redhat_packages
    else
        echo "All required packages are already installed."
    fi
else
    echo "Unsupported operating system."
    exit 1
fi

echo "Installation script completed."
