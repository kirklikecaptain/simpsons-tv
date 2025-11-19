#!/bin/bash
# init.sh - Initialize and update Raspberry Pi system

echo "Updating package lists..."
sudo apt update

echo "Upgrading installed packages..."
sudo apt full-upgrade -y

echo "Updating raspi-config..."
sudo apt install --only-upgrade raspi-config -y

echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean

echo "System update complete!"
echo "Reboot recommended: sudo reboot"