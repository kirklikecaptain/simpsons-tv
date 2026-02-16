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
sudo systemctl disable NetworkManager-wait-online.service

echo "Setting up SMB share for media folder..."
sudo cp -rf config/smb.conf /etc/samba/smb.conf
sudo systemctl enable smbd
sudo systemctl restart smbd

sudo systemctl disable apt-daily.timer apt-daily-upgrade.timer
sudo systemctl stop apt-daily.timer apt-daily-upgrade.timer

sudo systemctl disable NetworkManager.service
sudo systemctl stop NetworkManager.service

sudo systemctl enable dhcpcd
sudo systemctl start dhcpcd

sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
    ssid="RamboNet_Home"
    psk="J@3uEA2U9K2GjG.ReaT6"
}

network={
    ssid="AlecsMove"
    psk="951201main"
}
```
sudo chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf


# sudo apt install imagemagick
# convert image.png -colors 224 -depth 8 -type TrueColor -alpha off -compress none -define tga:bits-per-sample=8 splash-image.tga
# sudo apt install rpi-splash-screen-support