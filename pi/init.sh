#!/bin/bash

set -e

STV_PI_CONFIG=~/simpsons-tv/pi

echo "Installing LCD overlay..."
sudo cp -rf $STV_PI_CONFIG/boot/firmware/overlays/mhs35.dtbo /boot/firmware/overlays/mhs35.dtbo
sudo cp -rf $STV_PI_CONFIG/boot/firmware/config.txt /boot/firmware/config.txt
sudo cp -rf $STV_PI_CONFIG/boot/firmware/cmdline.txt /boot/firmware/cmdline.txt

echo "Disabling MOTD and setting console font..."
sudo truncate -s 0 /etc/motd
sudo truncate -s 0 /etc/issue
sudo truncate -s 0 /etc/issue.net
sudo chmod -x /etc/update-motd.d/*
sudo cp -rf $STV_PI_CONFIG/etc/default/console-setup /etc/default/console-setup

sudo apt install -y python3-pip python3-evdev
# pip3 install --break-system-packages -r ~/simpsons-tv/requirements.txt

sudo touch /home/pi/.hushlogin

printf 'clear\n' | cat - /home/pi/.profile | sudo tee /home/pi/.profile > /dev/null

# echo "Configuring autologin..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear --skip-login --noissue %I \$TERM
EOF
sudo systemctl daemon-reload
