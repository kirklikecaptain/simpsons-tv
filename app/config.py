"""Configuration constants for the Simpsons TV Kiosk application."""

import platform
from pathlib import Path

# Display configuration
SCREEN_WIDTH = 480
SCREEN_HEIGHT = 320
FPS = 30

# Media configuration
# Use ~/media/simpsons on Pi (Linux), _media/simpsons locally (macOS)
if platform.system() == "Linux":
    MEDIA_DIR = Path.home() / "media" / "simpsons"
else:
    MEDIA_DIR = Path(__file__).parent.parent / "_media" / "simpsons"

VIDEO_EXTENSIONS = {".mp4", ".avi", ".mkv", ".mov"}

# Touch configuration
LONG_PRESS_DURATION = 1000  # milliseconds (1 second)
DEBUG_MODE = True  # Set to False to hide debug overlays

# Colors
BLACK = (0, 0, 0)
YELLOW = (255, 215, 0)
WHITE = (255, 255, 255)
GRAY = (100, 100, 100)

# Debug overlay colors (RGBA with alpha for transparency)
DEBUG_MAIN_ZONE = (0, 255, 0, 50)  # Green with transparency
DEBUG_EXIT_ZONE = (255, 0, 0, 50)  # Red with transparency
DEBUG_TOUCH_POINT = (255, 255, 0)  # Yellow for touch indicators
