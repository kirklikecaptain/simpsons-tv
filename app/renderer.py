"""Rendering utilities for the kiosk display."""

import pygame
from .config import (
    SCREEN_WIDTH,
    SCREEN_HEIGHT,
    YELLOW,
    WHITE,
    GRAY,
    DEBUG_MODE,
    DEBUG_MAIN_ZONE,
    DEBUG_EXIT_ZONE,
    DEBUG_TOUCH_POINT,
)


def render_title(screen, font):
    """Render the main title."""
    title_text = font.render("Simpsons TV", True, WHITE)
    title_rect = title_text.get_rect(center=(SCREEN_WIDTH // 2, 40))
    screen.blit(title_text, title_rect)


def render_video_info(screen, small_font, selected_video):
    """Render the selected video filename."""
    if not selected_video:
        no_video_text = small_font.render("No videos found", True, WHITE)
        no_video_rect = no_video_text.get_rect(
            center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2)
        )
        screen.blit(no_video_text, no_video_rect)
        return

    video_name = selected_video.name
    if len(video_name) > 40:
        # Split long filenames into multiple lines
        mid = len(video_name) // 2
        split_point = video_name.rfind(" ", 0, mid + 10)
        if split_point == -1:
            split_point = mid

        line1 = video_name[:split_point]
        line2 = video_name[split_point:].strip()

        video_text1 = small_font.render(line1, True, WHITE)
        video_text2 = small_font.render(line2, True, WHITE)
        video_rect1 = video_text1.get_rect(
            center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 - 10)
        )
        video_rect2 = video_text2.get_rect(
            center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 + 10)
        )
        screen.blit(video_text1, video_rect1)
        screen.blit(video_text2, video_rect2)
    else:
        video_text = small_font.render(video_name, True, WHITE)
        video_rect = video_text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2))
        screen.blit(video_text, video_rect)


def render_ui_hints(screen, tiny_font, video_count):
    """Render UI hints and information."""
    # Exit zone hint
    exit_hint = tiny_font.render("Hold here to exit", True, GRAY)
    exit_hint_rect = exit_hint.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT - 30))
    screen.blit(exit_hint, exit_hint_rect)

    # Video count
    count_text = tiny_font.render(f"{video_count} videos", True, GRAY)
    count_rect = count_text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT - 10))
    screen.blit(count_text, count_rect)

    # Tap hint
    tap_hint = tiny_font.render("Tap for new video", True, GRAY)
    tap_hint_rect = tap_hint.get_rect(
        center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2 + 50)
    )
    screen.blit(tap_hint, tap_hint_rect)


def render_long_press_indicator(screen, is_long_pressing, touch_pos, exit_zone):
    """Render visual feedback for long press."""
    from .touch import is_point_in_rect

    if is_long_pressing and touch_pos:
        pulse = (pygame.time.get_ticks() // 200) % 2
        if pulse and is_point_in_rect(touch_pos, exit_zone):
            pygame.draw.circle(screen, YELLOW, touch_pos, 10)


def render_debug_overlay(screen, tiny_font, main_zone, exit_zone, touch_state):
    """Render debug overlays showing touch zones and active touches."""
    if not DEBUG_MODE:
        return

    # Create semi-transparent surface for zone overlays
    debug_surface = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT), pygame.SRCALPHA)

    # Draw main zone overlay (green)
    pygame.draw.rect(debug_surface, DEBUG_MAIN_ZONE, main_zone, 0)
    pygame.draw.rect(debug_surface, (0, 255, 0, 255), main_zone, 2)  # Border

    # Draw exit zone overlay (red)
    pygame.draw.rect(debug_surface, DEBUG_EXIT_ZONE, exit_zone, 0)
    pygame.draw.rect(debug_surface, (255, 0, 0, 255), exit_zone, 2)  # Border

    # Blit debug overlay
    screen.blit(debug_surface, (0, 0))

    # Show zone labels
    main_label = tiny_font.render("MAIN ZONE", True, (0, 255, 0))
    screen.blit(main_label, (10, 70))

    exit_label = tiny_font.render("EXIT ZONE", True, (255, 0, 0))
    screen.blit(exit_label, (10, SCREEN_HEIGHT - 50))

    # Show active touch point
    if touch_state.start_pos:
        pygame.draw.circle(screen, DEBUG_TOUCH_POINT, touch_state.start_pos, 8, 2)
        # Show touch duration
        duration = touch_state.get_duration()
        duration_text = tiny_font.render(f"{duration}ms", True, DEBUG_TOUCH_POINT)
        screen.blit(
            duration_text,
            (touch_state.start_pos[0] + 15, touch_state.start_pos[1] - 5),
        )
