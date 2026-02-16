"""Media file handling utilities."""

from pathlib import Path
from .config import MEDIA_DIR, VIDEO_EXTENSIONS


def get_video_files():
    """Get list of video files from media directory."""
    if not MEDIA_DIR.exists():
        print(f"Warning: Media directory not found: {MEDIA_DIR}")
        return []

    video_files = [
        f
        for f in MEDIA_DIR.iterdir()
        if f.is_file() and f.suffix.lower() in VIDEO_EXTENSIONS
    ]

    print(f"Found {len(video_files)} video files in {MEDIA_DIR}")
    return video_files
