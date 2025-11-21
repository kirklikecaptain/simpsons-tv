#!/bin/bash
# init.sh - Initialize and update Raspberry Pi system

set -e

echo "Updating package lists..."
sudo apt update

echo "Upgrading installed packages..."
sudo apt full-upgrade -y

echo "Installing required packages..."
sudo apt install --only-upgrade raspi-config -y
sudo apt install xserver-xorg-input-evdev xinput-calibrator matchbox-keyboard mplayer realvnc-vnc-server -y

echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean

echo "Use Xorg renderer instead of Wayland..."
sudo raspi-config nonint do_wayland W1

echo "Setting up bash aliases..."
cat >> ~/.bashrc << 'EOF'

# Config aliases for editing boot configuration files
alias edit-config='sudo nano /boot/firmware/config.txt'
alias edit-cmdline='sudo nano /boot/firmware/cmdline.txt'
EOF


echo "Installing LCD configuration files..."
sudo cp -f lcd/waveshare35a.dtbo /boot/overlays/waveshare35a.dtbo
sudo cp -f lcd/mhs35-overlay.dtbo /boot/overlays/mhs35.dtbo
sudo cp -f lcd/99-fbdev.conf /usr/share/X11/xorg.conf.d/99-fbdev.conf
sudo cp -f lcd/45-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf
sudo cp -f lcd/99-calibration.conf /usr/share/X11/xorg.conf.d/99-calibration.conf


echo "Installing system configuration files..."
sudo cp -f config/config.txt /boot/firmware/config.txt
sudo cp -f config/cmdline.txt /boot/firmware/cmdline.txt
sudo cp -f config/console-setup /etc/default/console-setup
cp -f config/.mplayer.conf ~/.mplayer/config


echo "Installing utilities..."
sudo cp -f scripts/toggle-matchbox-keyboard.sh /usr/local/bin/toggle-matchbox-keyboard.sh
sudo chmod +x /usr/local/bin/toggle-matchbox-keyboard.sh


echo "Disabling unnecessary services..."
sudo systemctl disable wifi-country.service
sudo systemctl disable ModemManager.service
sudo systemctl disable rsyslog.service
sudo systemctl disable keyboard-setup.service


echo "Configuring TTY1 for Python app..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=-/usr/bin/python3 /home/pi/simpsons-tv/app/main.py
StandardInput=tty
StandardOutput=tty
User=pi
Restart=always
Type=idle
EOF

echo "Configuring TTY2 for interactive access..."
sudo mkdir -p /etc/systemd/system/getty@tty2.service.d
sudo tee /etc/systemd/system/getty@tty2.service.d/override.conf > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear --noissue --skip-login %I $TERM
EOF

echo "Disabling TTY3-6..."
for i in {3..6}; do
    sudo systemctl disable getty@tty$i.service 2>/dev/null || true
done

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "TTY configuration complete!"
echo "  - TTY1: Python app (/home/pi/simpsons-tv/app/main.py)"
echo "  - TTY2: Interactive terminal (autologin)"
echo "  - TTY3-6: Disabled"

echo ""
echo "Installation complete!"
echo "Reboot to apply changes: sudo reboot"