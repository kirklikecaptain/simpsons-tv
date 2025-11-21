#!/usr/bin/env python3
import sys


def center_text(text):
    """Center text on the terminal screen"""
    try:
        # Get terminal size
        import shutil

        cols, rows = shutil.get_terminal_size()
    except:
        # Default if can't get size
        cols, rows = 80, 24

    # Calculate vertical centering
    top_padding = (rows - 1) // 2

    # Clear screen and move cursor to home
    print("\033[2J\033[H", end="")

    # Print empty lines for vertical centering
    print("\n" * top_padding, end="")

    # Print centered text
    print(text.center(cols))

    # Move cursor off screen
    print("\033[?25l", end="")  # Hide cursor
    sys.stdout.flush()


if __name__ == "__main__":
    center_text("Simpsons TV")

    # Keep running
    try:
        while True:
            import time

            time.sleep(1)
    except KeyboardInterrupt:
        # Show cursor on exit
        print("\033[?25h")
