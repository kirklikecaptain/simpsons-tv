#!/bin/bash
# disable-services.sh - Disable unnecessary services for faster boot

echo "Disabling unnecessary services..."

sudo systemctl disable wifi-country.service
sudo systemctl disable ModemManager.service
sudo systemctl disable rsyslog.service
sudo systemctl disable keyboard-setup.service

echo "Services disabled successfully."
echo "Reboot to see faster boot times."