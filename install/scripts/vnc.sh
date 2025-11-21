echo "Installing and configuring VNC..."
sudo apt install realvnc-vnc-server -y

# Create VNC config directory for pi user
mkdir -p ~/.vnc/config.d

# Configure VNC Virtual Mode with 720p resolution (passwordless)
cat > ~/.vnc/config.d/vncserver-virtual << 'EOF'
Geometry=1280x720
SecurityTypes=None
EOF

# Create xstartup for VNC desktop (runs as pi)
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources

xsetroot -solid grey

exec /usr/bin/lxsession -s LXDE-pi -e LXDE
EOF

chmod +x ~/.vnc/xstartup

# Skip password setup since SecurityTypes=None
echo "VNC configured for passwordless access"

# Create user systemd directory
mkdir -p ~/.config/systemd/user

# Create VNC service for pi user
cat > ~/.config/systemd/user/vncserver.service << 'EOF'
[Unit]
Description=VNC Server for pi user
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/vncserver-virtual -geometry 1280x720
ExecStop=/usr/bin/vncserver-virtual -kill :*
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

# Enable linger so service runs at boot without login
sudo loginctl enable-linger pi

# Enable and start user service
systemctl --user daemon-reload
systemctl --user enable vncserver.service
systemctl --user start vncserver.service

# Add aliases for management
cat >> ~/.bashrc << 'EOF'

# VNC aliases
alias vnc-status='systemctl --user status vncserver.service'
alias vnc-restart='systemctl --user restart vncserver.service'
alias vnc-stop='systemctl --user stop vncserver.service'
alias vnc-start='systemctl --user start vncserver.service'
EOF

echo "VNC configured to auto-start on boot at 1280x720!"
echo "WARNING: No password required - only use on trusted networks!"
echo "Connect to: <pi-ip>:5901"
echo "Manage with: vnc-status, vnc-restart, vnc-stop, vnc-start"