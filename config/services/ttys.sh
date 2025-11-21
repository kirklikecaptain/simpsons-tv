#!/bin/bash
# configure-ttys.sh - Configure TTY services for Simpsons TV

echo "Configuring TTY services..."

# TTY1 - Blank screen with custom message
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noclear --skip-login --login-options "-f root" --autologin root %I $TERM
StandardInput=tty
StandardOutput=tty
EOF

# Create the custom TTY1 script
sudo tee /usr/local/bin/tty1-message.sh > /dev/null << 'EOF'
#!/bin/bash
# Clear screen and show message
clear
setterm -cursor off
echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║                                     ║"
echo "  ║             SIMPSONS TV             ║"
echo "  ║                                     ║"
echo "  ╚══════════════════════════════════╝"
echo ""
# Keep terminal open, suppress bash prompt
exec bash --norc --noprofile > /dev/null 2>&1
EOF

sudo chmod +x /usr/local/bin/tty1-message.sh

# Configure root's bashrc to run the message on tty1
sudo tee -a /root/.bashrc > /dev/null << 'EOF'

# Auto-run custom message on tty1
if [ "$(tty)" = "/dev/tty1" ]; then
    /usr/local/bin/tty1-message.sh
fi
EOF

# TTY2 - Auto-login for log viewing
sudo mkdir -p /etc/systemd/system/getty@tty2.service.d
sudo tee /etc/systemd/system/getty@tty2.service.d/override.conf > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM
EOF

# Disable TTY3-6
for i in {3..6}; do
    sudo systemctl disable getty@tty$i.service 2>/dev/null
    sudo systemctl stop getty@tty$i.service 2>/dev/null
done

# Reload systemd and restart services
sudo systemctl daemon-reload
sudo systemctl restart getty@tty1.service
sudo systemctl restart getty@tty2.service
