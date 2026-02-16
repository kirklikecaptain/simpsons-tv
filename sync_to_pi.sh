#!/bin/bash

# CONFIG
PI_HOST=admin@kirks-pi-tv.local
PI_DIR=/home/admin/simpsons-tv

# SYNC
rsync -avz \
  --exclude-from='.pi-sync-ignore' \
  ./ $PI_HOST:$PI_DIR

echo "Running app on Pi..."
ssh $PI_HOST "cd $PI_DIR/app && sudo python3 simpsons_kiosk.py"