---
name: ffmpeg-video-editor
description: "Comprehensive FFmpeg CLI video editing - cuts, effects, transitions, audio, zoom/pan, color correction, and more. Use when the user wants CLI-based video processing, automation, or batch editing."
---

# FFmpeg Video Editor

CLI-based video editing using FFmpeg for cuts, effects, transitions, audio, zoom/pan, and color correction.

## Run local preflight checks

- Verify FFmpeg is installed: `command -v ffmpeg`
- Verify FFprobe is installed: `command -v ffprobe`
- Stop if either binary is missing from PATH.

## Core principles

- FFmpeg does everything MoviePy does (MoviePy is just a Python wrapper).
- Use `-vf` for video filters, `-af` for audio filters.
- Chain filters with commas (`,`) for sequential, semicolons (`;`) for complex graphs.
- Use `-c:v` and `-c:a` to specify codecs (copy, libx264, aac, etc.).
- Always specify input/output files with `-i`.

## Supported workflows

- **Basic operations**: Cut, trim, concat, split, merge
- **Video effects**: Brightness, contrast, saturation, blur, sharpen, denoise
- **Transitions**: Fade in/out, crossfade, dissolve
- **Zoom & pan**: Ken Burns, close-up, crop, scale, pan
- **Audio**: Add, mix, volume, fade, speed change
- **Color correction**: Hue, temperature, tint, color wheels
- **Text overlays**: Drawtext, subtitles
- **Format conversion**: Codec, container, resolution, bitrate
- **Batch processing**: Multiple files, scripted workflows

## Keep the workflow lean

- Prefer the smallest command that satisfies the request.
- Use `-c copy` when possible to avoid re-encoding.
- Load [references/ffmpeg-commands.md](references/ffmpeg-commands.md) for exact command patterns.
- Do not add unnecessary wrappers or unrelated features.
