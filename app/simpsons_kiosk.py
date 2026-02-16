#!/usr/bin/env python3
"""
Simpsons TV Kiosk Application
Runs on macOS (windowed) and Raspberry Pi OS Lite (framebuffer)
"""

import os
import sys
import platform
import random
import pygame

from .config import SCREEN_WIDTH, SCREEN_HEIGHT, FPS, BLACK, LONG_PRESS_DURATION
from .media import get_video_files
from .touch import TouchState, is_point_in_rect, create_touch_zones
from .renderer import (
    render_title,
    render_video_info,
    render_ui_hints,
    render_long_press_indicator,
    render_debug_overlay,
)


def setup_environment():
    """Configure environment variables based on platform."""
    system = platform.system()

    if system == "Linux":
        # Running on Raspberry Pi - configure for framebuffer
        os.environ["SDL_VIDEODRIVER"] = "fbcon"
        os.environ["SDL_FBDEV"] = "/dev/fb0"
        os.environ["SDL_NOMOUSE"] = "1"
        # Enable touch input on Linux
        os.environ["SDL_MOUSEDRV"] = "TSLIB"
        os.environ["SDL_MOUSEDEV"] = "/dev/input/touchscreen"
        print("Configured for Linux framebuffer (fb0) with touch input")
    else:
        # Running on macOS or other - use default windowed mode
        print(f"Configured for {system} windowed mode")


def main():
    """Main application entry point."""

    # Setup environment for platform
    setup_environment()

    # Get video files and select a random one
    video_files = get_video_files()
    selected_video = random.choice(video_files) if video_files else None

    if selected_video:
        print(f"Selected video: {selected_video.name}")
    else:
        print("No video files found")

    # Initialize pygame
    pygame.init()

    # Create display surface
    screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
    pygame.display.set_caption("Simpsons TV Kiosk")

    # Create clock for FPS control
    clock = pygame.time.Clock()

    # Use default pygame fonts
    font = pygame.font.Font(None, 32)
    small_font = pygame.font.Font(None, 24)
    tiny_font = pygame.font.Font(None, 18)

    # Initialize touch state and zones
    touch_state = TouchState()
    main_zone, exit_zone = create_touch_zones()

    print(f"Display initialized: {SCREEN_WIDTH}x{SCREEN_HEIGHT}")
    print("Touch zones: Main area = new video, Bottom area long press = exit")

    # Main event loop
    running = True
    while running:
        # Handle events
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                if event.key in (pygame.K_ESCAPE, pygame.K_q):
                    running = False
            elif event.type == pygame.MOUSEBUTTONDOWN:
                # Touch started
                touch_state.start_touch(event.pos)
            elif event.type == pygame.MOUSEBUTTONUP:
                # Touch ended
                touch_duration = touch_state.end_touch()
                saved_pos = touch_state.start_pos  # Save before reset

                if touch_duration and saved_pos:
                    # Check if it was a long press in exit zone
                    if touch_duration >= LONG_PRESS_DURATION:
                        if is_point_in_rect(saved_pos, exit_zone):
                            print("Long press in exit zone - exiting")
                            running = False
                    else:
                        # Short tap - select new random video if in main zone
                        if is_point_in_rect(saved_pos, main_zone) and video_files:
                            selected_video = random.choice(video_files)
                            print(f"New video selected: {selected_video.name}")

            elif event.type == pygame.FINGERDOWN:
                # Direct touch input on touchscreen
                x = int(event.x * SCREEN_WIDTH)
                y = int(event.y * SCREEN_HEIGHT)
                touch_state.start_touch((x, y))

        # Update touch state (check for long press)
        if touch_state.update() and touch_state.start_pos:
            if is_point_in_rect(touch_state.start_pos, exit_zone):
                print("Long press detected in exit zone")

        # Clear screen
        screen.fill(BLACK)

        # Render all UI elements
        render_title(screen, font)
        render_video_info(screen, small_font, selected_video)
        render_ui_hints(screen, tiny_font, len(video_files))
        render_long_press_indicator(
            screen, touch_state.is_long_pressing, touch_state.start_pos, exit_zone
        )
        render_debug_overlay(screen, tiny_font, main_zone, exit_zone, touch_state)

        # Update display
        pygame.display.flip()

        # Control frame rate
        clock.tick(FPS)

    # Cleanup
    pygame.quit()
    print("Application closed")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrupted by user")
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
