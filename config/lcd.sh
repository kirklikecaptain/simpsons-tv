#!/bin/sh

sudo apt install xserver-xorg-input-evdev xinput-calibrator matchbox-keyboard -y
sudo cp -rf lcd/waveshare35a.dtbo /boot/overlays/waveshare35a.dtbo
sudo cp -rf lcd/mhs35-overlay.dtbo /boot/overlays/mhs35.dtbo
sudo cp -rf lcd/99-fbdev.conf /usr/share/X11/xorg.conf.d/99-fbdev.conf
sudo cp -rf lcd/45-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf
sudo cp -rf lcd/99-calibration.conf /usr/share/X11/xorg.conf.d/99-calibration.conf
sudo cp -rf lcd/config.txt /boot/firmware/config.txt
sudo cp -rf lcd/cmdline.txt /boot/firmware/cmdline.txt
sudo cp -rf lcd/console-setup /etc/default/console-setup
sudo cp -rf lcd/toggle-matchbox-keyboard.sh /usr/local/bin/toggle-matchbox-keyboard.sh
sudo chmod +x /usr/local/bin/toggle-matchbox-keyboard.sh

echo "Now reboot for changes to take effect.."