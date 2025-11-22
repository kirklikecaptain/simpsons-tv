#!/bin/bash
# init.sh - Initialize and update Raspberry Pi system

# Don't exit on error - we'll handle errors manually
set +e

# Setup logging
LOG_FILE="$(dirname "$0")/install_$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="$(dirname "$0")/install_errors_$(date +%Y%m%d_%H%M%S).log"
CRITICAL_ERROR=0

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE" "$ERROR_LOG" >&2
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1" | tee -a "$LOG_FILE"
}

log_critical() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] CRITICAL ERROR: $1" | tee -a "$LOG_FILE" "$ERROR_LOG" >&2
    CRITICAL_ERROR=1
}

log "Starting installation..."

log "Updating package lists..."
if sudo apt update >> "$LOG_FILE" 2>&1; then
    log_success "Package lists updated"
else
    log_critical "Failed to update package lists - cannot continue without network/package access"
    exit 1
fi

log "Upgrading installed packages..."
if sudo apt full-upgrade -y >> "$LOG_FILE" 2>&1; then
    log_success "Packages upgraded"
else
    log_error "Failed to upgrade packages (non-critical, continuing)"
fi

log "Installing required packages..."
if sudo apt install --only-upgrade raspi-config -y >> "$LOG_FILE" 2>&1; then
    log_success "raspi-config upgraded"
else
    log_error "Failed to upgrade raspi-config (non-critical)"
fi

if sudo apt install xserver-xorg-input-evdev xinput-calibrator matchbox-keyboard mplayer realvnc-vnc-server -y >> "$LOG_FILE" 2>&1; then
    log_success "Required packages installed"
else
    log_error "Failed to install some packages (non-critical, continuing)"
fi

log "Cleaning up..."
sudo apt autoremove -y >> "$LOG_FILE" 2>&1
sudo apt clean >> "$LOG_FILE" 2>&1
log_success "Cleanup complete"

log "Setting Xorg renderer instead of Wayland..."
if sudo raspi-config nonint do_wayland W1 >> "$LOG_FILE" 2>&1; then
    log_success "Xorg renderer configured"
else
    log_error "Failed to configure Xorg renderer (non-critical)"
fi

log "Installing LCD configuration files..."
failed_files=0
sudo cp -f lcd/waveshare35a.dtbo /boot/overlays/waveshare35a.dtbo 2>> "$ERROR_LOG" || { log_error "Failed to copy waveshare35a.dtbo"; ((failed_files++)); }
sudo cp -f lcd/mhs35-overlay.dtbo /boot/overlays/mhs35.dtbo 2>> "$ERROR_LOG" || { log_error "Failed to copy mhs35-overlay.dtbo"; ((failed_files++)); }
sudo cp -f lcd/99-fbdev.conf /usr/share/X11/xorg.conf.d/99-fbdev.conf 2>> "$ERROR_LOG" || { log_error "Failed to copy 99-fbdev.conf"; ((failed_files++)); }
sudo cp -f lcd/45-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf 2>> "$ERROR_LOG" || { log_error "Failed to copy 45-evdev.conf"; ((failed_files++)); }
sudo cp -f lcd/99-calibration.conf /usr/share/X11/xorg.conf.d/99-calibration.conf 2>> "$ERROR_LOG" || { log_error "Failed to copy 99-calibration.conf"; ((failed_files++)); }

if [ $failed_files -eq 0 ]; then
    log_success "LCD configuration files installed"
else
    log_error "Failed to install $failed_files LCD configuration file(s) (non-critical)"
fi

log "Installing system configuration files..."
failed_configs=0
sudo cp -f config/config.txt /boot/firmware/config.txt 2>> "$ERROR_LOG" || { log_error "Failed to copy config.txt"; ((failed_configs++)); }
sudo cp -f config/cmdline.txt /boot/firmware/cmdline.txt 2>> "$ERROR_LOG" || { log_error "Failed to copy cmdline.txt"; ((failed_configs++)); }
sudo cp -f config/console-setup /etc/default/console-setup 2>> "$ERROR_LOG" || { log_error "Failed to copy console-setup"; ((failed_configs++)); }
sudo cp -f config/.mplayer ~/.mplayer 2>> "$ERROR_LOG" || { log_error "Failed to copy .mplayer config"; ((failed_configs++)); }
sudo cp -f config/.bash_aliases ~/.bash_aliases 2>> "$ERROR_LOG" || { log_error "Failed to copy .bash_aliases"; ((failed_configs++)); }

if [ $failed_configs -eq 0 ]; then
    log_success "System configuration files installed"
else
    log_error "Failed to install $failed_configs system configuration file(s) (non-critical)"
fi

log "Installing utilities..."
if sudo cp -f scripts/toggle-matchbox-keyboard.sh /usr/local/bin/toggle-matchbox-keyboard.sh 2>> "$ERROR_LOG" && \
   sudo chmod +x /usr/local/bin/toggle-matchbox-keyboard.sh 2>> "$ERROR_LOG"; then
    log_success "Utilities installed"
else
    log_error "Failed to install utilities (non-critical)"
fi

log "Configuring TTY1..."
if sudo mkdir -p /etc/systemd/system/getty@tty1.service.d 2>> "$ERROR_LOG" && \
   sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty %I $TERM
EOF
then
    log_success "TTY1 configured"
else
    log_error "Failed to configure TTY1 (non-critical)"
fi

log "Configuring TTY2 for interactive access..."
if sudo mkdir -p /etc/systemd/system/getty@tty2.service.d 2>> "$ERROR_LOG" && \
   sudo tee /etc/systemd/system/getty@tty2.service.d/override.conf > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noissue --skip-login %I $TERM
EOF
then
    log_success "TTY2 configured"
else
    log_error "Failed to configure TTY2 (non-critical)"
fi

log "Reloading systemd..."
if sudo systemctl daemon-reload >> "$LOG_FILE" 2>&1; then
    log_success "Systemd reloaded"
else
    log_error "Failed to reload systemd (non-critical)"
fi

log_success "Installation complete!"
log "  - TTY1: Standard getty"
log "  - TTY2: Interactive terminal (autologin)"

echo ""
echo "============================================"
echo "Installation complete!"
echo "============================================"
echo "Log file: $LOG_FILE"
if [ -f "$ERROR_LOG" ]; then
    echo "Error log: $ERROR_LOG"
    echo "Note: Some non-critical errors occurred (see error log)"
fi
if [ $CRITICAL_ERROR -eq 1 ]; then
    echo ""
    echo "CRITICAL ERRORS OCCURRED - Review logs before rebooting"
    exit 1
else
    echo ""
    echo "Reboot to apply changes: sudo reboot"
    exit 0
fi