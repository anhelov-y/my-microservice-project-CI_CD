#!/bin/bash

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
    echo "Successfully installed Docker."
fi

# Docker Compose
if ! check_install docker-compose; then
    sudo apt install -y docker-compose
    echo "Successfully installed Docker Compose."
fi

# Python 3
if ! check_install python3; then
    sudo apt install -y python3
    echo "Successfully installed Python."
fi

# Перевірка версії
echo -n "Current Python version: "
python3 --version

# Django
if ! check_install django-admin; then
    sudo apt install -y python3-pip
    # Використовуємо обхід для нових версій Ubuntu
    pip3 install django --break-system-packages
    echo "Successfully installed Django."
fi

echo "_____All packages checked and installed_____"