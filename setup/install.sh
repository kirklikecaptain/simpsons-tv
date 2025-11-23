#!/bin/bash

echo "Updating package lists..."
sudo apt update

echo "Upgrading installed packages..."
sudo apt full-upgrade -y
echo "Upgrading raspi-config..."
sudo apt install --only-upgrade raspi-config -y

echo "Installing packages..."
sudo apt install xserver-xorg-input-evdev xinput-calibrator matchbox-keyboard mplayer -y

echo "Setting Xorg as the default renderer..."
sudo raspi-config nonint do_wayland W1

echo "Setting boot to console with autologin..."
sudo raspi-config nonint do_boot_behaviour B2

echo "Updating boot configuration files..."
sudo cp -rf config/cmdline.txt /boot/firmware/cmdline.txt
sudo cp -rf config/config.txt /boot/firmware/config.txt

echo "Installing LCD configuration files..."
sudo cp -rf lcd/waveshare35a.dtbo /boot/overlays/waveshare35a.dtbo
sudo cp -rf lcd/mhs35.dtbo /boot/overlays/mhs35.dtbo
sudo cp -rf lcd/99-calibration.conf /usr/share/X11/xorg.conf.d/99-calibration.conf
sudo cp -rf lcd/45-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf
sudo cp -rf lcd/99-fbdev.conf /usr/share/X11/xorg.conf.d/99-fbdev.conf

mkdir ~/.mplayer
cp -rf config/.mplayer_config ~/.mplayer/config
cp -rf config/.bash_aliases ~/.bash_aliases
cp -rf config/.bashrc ~/.bashrc


echo "Creating console font service..."
sudo cp -rf config/console-setup /etc/default/console-setup
sudo cp -rf services/setupcon-early.service /etc/systemd/system/setupcon-early.service
sudo systemctl enable setupcon-early.service
