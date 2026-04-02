#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo."
  exit 1
fi

echo "Updating packages indexes..."
sudo apt update -y


check_install() {
    if command -v $1 &> /dev/null; then
        echo "$1 already installed."
        return 0
    else
        echo "$1 not found. Installing..."
        return 1
    fi
}

# Встановлення Docker
if ! check_install docker; then
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    usermod -aG docker "$SUDO_USER"
    echo "Successfully installed Docker and updated user groups."
fi

# Docker Compose
if ! docker compose version &> /dev/null; then
    echo "Installing docker-compose-plugin..."
    sudo apt install -y docker-compose-plugin
    echo "Successfully installed Docker Compose Plugin."
else
    echo "Docker Compose (plugin) already installed."
fi

# Python 3
if ! check_install python3; then
    sudo apt install -y python3
    echo "Successfully installed Python."
fi

# Перевірка версії
echo -n "Current Python version: "
python3 --version
PYTHON_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

# Django
if ! check_install django-admin; then
    sudo apt install -y python3-pip
    # Використовуємо твій перевірений флаг
    pip3 install django --break-system-packages
    echo "Successfully installed Django."
fi

echo "_____All packages checked and installed_____"