# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repo configures a Raspberry Pi to run as a Simpsons TV prop — a physical device with a 3.5" MHS35 LCD screen that plays Simpsons episodes. Development happens on macOS; the Pi runs Raspberry Pi OS Lite (Trixie, 64-bit).

## Key Commands

```bash
# Sync repo files to the Pi (uses rsync, respects .gitignore)
make sync

# Sync media files separately (large, kept out of git)
make sync-media

# Full Pi initialization: creates app dir, syncs, and runs init.sh
make init-pi
```

The default target device is `pi@kirks-pi-tv.local`. Override with `HOSTNAME=` or `NAME=`.

## Architecture

**`pi/`** — Files that get deployed to the Pi via `make sync`:

- `pi/init.sh` — Bootstrap script run over SSH (`make init-pi`). Installs apt packages, copies boot config files, configures autologin for the `pi` user, and cleans up login noise.
- `pi/boot/firmware/config.txt` — Pi boot config: enables SPI for LCD, audio on GPIO13 (mono PWM), and loads the `mhs35:rotate=270` device tree overlay.
- `pi/boot/firmware/cmdline.txt` — Kernel cmdline: maps framebuffer to the LCD (`fbcon=map:1`), disables cursor, routes video away from HDMI.
- `pi/boot/firmware/overlays/mhs35.dtbo` — Compiled device tree blob for the MHS35 LCD.
- `pi/etc/default/console-setup` — Sets Terminus 8x14 font for the console.

**`media/`** — Not committed to git (only `media/.gitkeep` is tracked). Contains:

- `media/simpsons/` — Episode files (`S01E01. ...mp4` naming convention)
- `media/misc/` — `startup.mp3`, `shutdown.mp3`, `static.mp4`

## Deployment Flow

1. Flash Pi with Raspberry Pi OS Lite Trixie 64-bit
2. SSH in and clone the repo
3. Run `make init-pi` from the dev machine (or run `pi/init.sh` directly on the Pi)
4. Copy media separately with `make sync-media`

After initial setup, use `make sync` to push code changes to the Pi.
