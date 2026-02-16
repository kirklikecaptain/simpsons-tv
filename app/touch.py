"""Touch input handling for resistive touchscreen."""

import pygame
from .config import SCREEN_WIDTH, SCREEN_HEIGHT, LONG_PRESS_DURATION


class TouchState:
    """Manages touch state and interactions."""

    def __init__(self):
        self.start_time = None
        self.start_pos = None
        self.is_long_pressing = False

    def start_touch(self, pos):
        """Register the start of a touch event."""
        self.start_pos = pos
        self.start_time = pygame.time.get_ticks()
        self.is_long_pressing = False
        print(f"Touch started at: {pos}")

    def end_touch(self):
        """Calculate touch duration and reset state."""
        if not self.start_time:
            return 0

        duration = pygame.time.get_ticks() - self.start_time
        self.start_time = None
        self.start_pos = None
        self.is_long_pressing = False
        return duration

    def update(self):
        """Update touch state - check for long press."""
        if self.start_time and not self.is_long_pressing:
            duration = pygame.time.get_ticks() - self.start_time
            if duration >= LONG_PRESS_DURATION:
                self.is_long_pressing = True
                return True
        return False

    def get_duration(self):
        """Get current touch duration in milliseconds."""
        if not self.start_time:
            return 0
        return pygame.time.get_ticks() - self.start_time


def is_point_in_rect(point, rect):
    """Check if a point (x, y) is inside a rectangle."""
    x, y = point
    return rect.left <= x <= rect.right and rect.top <= y <= rect.bottom


def create_touch_zones():
    """Create and return touch zone rectangles."""
    # Main zone: tap anywhere to get new random video
    main_zone = pygame.Rect(0, 60, SCREEN_WIDTH, SCREEN_HEIGHT - 120)
    # Exit zone: bottom area for long press to exit
    exit_zone = pygame.Rect(0, SCREEN_HEIGHT - 60, SCREEN_WIDTH, 60)

    return main_zone, exit_zone
