#!/bin/bash

# sudo nano /usr/local/bin/smbd-postlogin.sh
# sudo chmod +x /usr/local/bin/smbd-postlogin.sh

# Wait for wlan0 to get an IP address
timeout=20
count=0
while ! ip addr show wlan0 | grep -q 'inet '; do
    sleep 1
    count=$((count + 1))
    if [ "$count" -ge "$timeout" ]; then
        echo "Timed out waiting for wlan0"
        exit 1
    fi
done

# Check if user is logged in on tty1 or tty2
if who | grep -q 'admin.*tty[1-2]'; then
    echo "User admin is logged in on TTY, starting smbd"
    systemctl start smbd.service
else
    echo "User not logged in on TTY yet"
    exit 1
fi
