#!/bin/bash
# init.sh - Initialize and update Raspberry Pi system

# Don't exit on error - we'll handle errors manually
set +e

# Setup logging and backup directory
SCRIPT_DIR="$(dirname "$0")"
LOG_FILE="$SCRIPT_DIR/install_$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="$SCRIPT_DIR/install_errors_$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="$SCRIPT_DIR/backups_$(date +%Y%m%d_%H%M%S)"
CRITICAL_ERROR=0

# Create backup directory
mkdir -p "$BACKUP_DIR"

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

# Function to backup a file
backup_file() {
    local src="$1"
    local backup_name="$2"

    if [ -f "$src" ]; then
        local backup_path="$BACKUP_DIR/$backup_name"
        mkdir -p "$(dirname "$backup_path")"
        if cp "$src" "$backup_path" 2>> "$ERROR_LOG"; then
            log "Backed up: $src -> $backup_path"
            echo "$src|$backup_path" >> "$BACKUP_DIR/backup_manifest.txt"
            return 0
        else
            log_error "Failed to backup: $src"
            return 1
        fi
    else
        log "No existing file to backup: $src"
        return 0
    fi
}

log "Starting installation..."
log "Backup directory: $BACKUP_DIR"

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

backup_file "/boot/overlays/waveshare35a.dtbo" "boot/overlays/waveshare35a.dtbo"
sudo cp -f lcd/waveshare35a.dtbo /boot/overlays/waveshare35a.dtbo 2>> "$ERROR_LOG" || { log_error "Failed to copy waveshare35a.dtbo"; ((failed_files++)); }

backup_file "/boot/overlays/mhs35.dtbo" "boot/overlays/mhs35.dtbo"
sudo cp -f lcd/mhs35-overlay.dtbo /boot/overlays/mhs35.dtbo 2>> "$ERROR_LOG" || { log_error "Failed to copy mhs35-overlay.dtbo"; ((failed_files++)); }

backup_file "/usr/share/X11/xorg.conf.d/99-fbdev.conf" "usr/share/X11/xorg.conf.d/99-fbdev.conf"
sudo cp -f lcd/99-fbdev.conf /usr/share/X11/xorg.conf.d/99-fbdev.conf 2>> "$ERROR_LOG" || { log_error "Failed to copy 99-fbdev.conf"; ((failed_files++)); }

backup_file "/usr/share/X11/xorg.conf.d/45-evdev.conf" "usr/share/X11/xorg.conf.d/45-evdev.conf"
sudo cp -f lcd/45-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf 2>> "$ERROR_LOG" || { log_error "Failed to copy 45-evdev.conf"; ((failed_files++)); }

backup_file "/usr/share/X11/xorg.conf.d/99-calibration.conf" "usr/share/X11/xorg.conf.d/99-calibration.conf"
sudo cp -f lcd/99-calibration.conf /usr/share/X11/xorg.conf.d/99-calibration.conf 2>> "$ERROR_LOG" || { log_error "Failed to copy 99-calibration.conf"; ((failed_files++)); }

if [ $failed_files -eq 0 ]; then
    log_success "LCD configuration files installed"
else
    log_error "Failed to install $failed_files LCD configuration file(s) (non-critical)"
fi

log "Installing system configuration files..."
failed_configs=0

backup_file "/boot/firmware/config.txt" "boot/firmware/config.txt"
sudo cp -f config/config.txt /boot/firmware/config.txt 2>> "$ERROR_LOG" || { log_error "Failed to copy config.txt"; ((failed_configs++)); }

backup_file "/boot/firmware/cmdline.txt" "boot/firmware/cmdline.txt"
sudo cp -f config/cmdline.txt /boot/firmware/cmdline.txt 2>> "$ERROR_LOG" || { log_error "Failed to copy cmdline.txt"; ((failed_configs++)); }

backup_file "/etc/default/console-setup" "etc/default/console-setup"
sudo cp -f config/console-setup /etc/default/console-setup 2>> "$ERROR_LOG" || { log_error "Failed to copy console-setup"; ((failed_configs++)); }

backup_file "$HOME/.bash_aliases" "home/.bash_aliases"
sudo cp -f config/.bash_aliases ~/.bash_aliases 2>> "$ERROR_LOG" || { log_error "Failed to copy .bash_aliases"; ((failed_configs++)); }

backup_file "/etc/motd" "etc/motd"
sudo cp -f config/motd /etc/motd 2>> "$ERROR_LOG" || { log_error "Failed to copy motd"; ((failed_configs++)); }


backup_file "$HOME/.mplayer/config" "home/.mplayer/config"
mkdir -p ~/.mplayer
sudo cp -f config/.mplayer ~/.mplayer/config 2>> "$ERROR_LOG" || { log_error "Failed to copy .mplayer config"; ((failed_configs++)); }

if [ $failed_configs -eq 0 ]; then
    log_success "System configuration files installed"
else
    log_error "Failed to install $failed_configs system configuration file(s) (non-critical)"
fi

log "Installing utilities..."
backup_file "/usr/local/bin/toggle-matchbox-keyboard.sh" "usr/local/bin/toggle-matchbox-keyboard.sh"
if sudo cp -f scripts/toggle-matchbox-keyboard.sh /usr/local/bin/toggle-matchbox-keyboard.sh 2>> "$ERROR_LOG" && \
   sudo chmod +x /usr/local/bin/toggle-matchbox-keyboard.sh 2>> "$ERROR_LOG"; then
    log_success "Utilities installed"
else
    log_error "Failed to install utilities (non-critical)"
fi

log "Disabling unnecessary services..."
sudo systemctl disable ModemManager.service >> "$LOG_FILE" 2>&1 || log_error "Failed to disable ModemManager (non-critical)"
sudo systemctl disable keyboard-setup.service >> "$LOG_FILE" 2>&1 || log_error "Failed to disable keyboard-setup (non-critical)"
log_success "Unnecessary services processing complete"

log "Configuring TTY1..."
backup_file "/etc/systemd/system/getty@tty1.service.d/override.conf" "etc/systemd/system/getty@tty1.service.d/override.conf"
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
backup_file "/etc/systemd/system/getty@tty2.service.d/override.conf" "etc/systemd/system/getty@tty2.service.d/override.conf"
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
echo "Backup directory: $BACKUP_DIR"
if [ -f "$ERROR_LOG" ]; then
    echo "Error log: $ERROR_LOG"
    echo "Note: Some non-critical errors occurred (see error log)"
fi
if [ $CRITICAL_ERROR -eq 1 ]; then
    echo ""
    echo "CRITICAL ERRORS OCCURRED - Review logs before rebooting"
    echo "To restore backups, run: ./restore.sh $BACKUP_DIR"
    exit 1
else
    echo ""
    echo "To restore backups if needed, run: ./restore.sh $BACKUP_DIR"
    echo "Reboot to apply changes: sudo reboot"
    exit 0
fi