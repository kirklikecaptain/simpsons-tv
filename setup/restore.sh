#!/bin/bash
# restore.sh - Restore backed up system files

set -e

BACKUP_DIR="$1"

if [ -z "$BACKUP_DIR" ]; then
    echo "Usage: $0 <backup_directory>"
    echo ""
    echo "Available backups:"
    ls -d backups_* 2>/dev/null || echo "  No backups found"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Backup directory not found: $BACKUP_DIR"
    exit 1
fi

if [ ! -f "$BACKUP_DIR/backup_manifest.txt" ]; then
    echo "Error: Backup manifest not found in $BACKUP_DIR"
    exit 1
fi

echo "Restoring from backup: $BACKUP_DIR"
echo "============================================"
echo ""

restored=0
failed=0

while IFS='|' read -r dest src; do
    if [ -f "$src" ]; then
        echo "Restoring: $dest"
        if sudo cp -f "$src" "$dest" 2>/dev/null; then
            ((restored++))
        else
            echo "  ERROR: Failed to restore $dest"
            ((failed++))
        fi
    else
        echo "  SKIP: Backup file not found: $src"
    fi
done < "$BACKUP_DIR/backup_manifest.txt"

echo ""
echo "============================================"
echo "Restore complete!"
echo "  Files restored: $restored"
if [ $failed -gt 0 ]; then
    echo "  Failed: $failed"
fi
echo "============================================"

if [ $failed -eq 0 ]; then
    echo ""
    echo "Reloading systemd..."
    sudo systemctl daemon-reload
    echo ""
    echo "All files restored successfully!"
    echo "Reboot to apply changes: sudo reboot"
    exit 0
else
    echo ""
    echo "Some files failed to restore. Review errors above."
    exit 1
fi