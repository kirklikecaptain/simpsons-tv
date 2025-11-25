#!/bin/bash

echo "Updating package lists and installing packages..."
sudo apt update
sudo apt install xserver-xorg-input-evdev xinput-calibrator matchbox-keyboard mplayer samba samba-common-bin fbi -y

echo "Configuring boot to tty1..."
sudo systemctl set-default multi-user.target
sudo ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
sudo systemctl daemon-reload

echo "Updating boot configuration files..."
sudo cp -rf config/cmdline.txt /boot/firmware/cmdline.txt
sudo cp -rf config/config.txt /boot/firmware/config.txt

echo "Installing LCD configuration files..."
sudo cp -rf lcd/waveshare35a.dtbo /boot/overlays/waveshare35a.dtbo
sudo cp -rf lcd/mhs35.dtbo /boot/overlays/mhs35.dtbo
sudo cp -rf lcd/99-calibration.conf /usr/share/X11/xorg.conf.d/99-calibration.conf
sudo cp -rf lcd/45-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf
sudo cp -rf lcd/99-fbdev.conf /usr/share/X11/xorg.conf.d/99-fbdev.conf

echo "Copying user configuration files..."
mkdir -p ~/.mplayer
cp -rf config/.mplayer_config ~/.mplayer/config
cp -rf config/.bash_aliases ~/.bash_aliases
cp -rf config/.bashrc ~/.bashrc

echo "Creating console font service..."
sudo cp -rf config/console-setup /etc/default/console-setup

sudo touch /etc/cloud/cloud-init.disabled
sudo systemctl disable --now ModemManager

echo "Setting up SMB share for media folder..."
sudo cp -rf config/smb.conf /etc/samba/smb.conf
sudo systemctl enable smbd
sudo systemctl restart smbd

# sudo apt install imagemagick
# convert image.png -colors 224 -depth 8 -type TrueColor -alpha off -compress none -define tga:bits-per-sample=8 splash-image.tga
# sudo apt install rpi-splash-screen-support