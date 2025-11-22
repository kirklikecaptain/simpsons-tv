# Bluetooth
sudo systemctl disable bluetooth.service
sudo systemctl disable hciuart.service

# Networking (if using WiFi only)
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl disable systemd-networkd-wait-online.service

# Printer support
sudo systemctl disable cups.service
sudo systemctl disable cups-browsed.service

# Audio services (if not needed)
# sudo systemctl disable alsa-restore.service
# sudo systemctl disable alsa-state.service

# Misc
sudo systemctl disable apt-daily.service
sudo systemctl disable apt-daily-upgrade.service
sudo systemctl disable man-db.service
sudo systemctl disable triggerhappy.service

# Disable system service
sudo systemctl disable bluetooth.service

# Create user service
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/bluetooth.service << 'EOF'
[Unit]
Description=Bluetooth service (delayed)
After=default.target

[Service]
Type=dbus
BusName=org.bluez
ExecStart=/usr/libexec/bluetooth/bluetoothd

[Install]
WantedBy=default.target
EOF

systemctl --user enable bluetooth.service