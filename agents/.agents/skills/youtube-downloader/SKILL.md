---
name: youtube-downloader
description: "Download a YouTube video or extract audio to mp3 using locally installed yt-dlp and ffmpeg (ffprobe optional for inspection). Use for format inspection, video download, or audio extraction from a single YouTube URL."
---

# YouTube Downloader

Download a single YouTube video or extract its audio using yt-dlp and ffmpeg.

## Run local preflight checks

- Verify required binaries before running commands:
  - `command -v yt-dlp`
  - `command -v ffmpeg`
  - `command -v ffprobe`
- Stop if any binary is missing from `PATH`.
- Prefer a local destination directory and title-based output templates; verify the actual resulting filename before follow-up commands since yt-dlp or ffmpeg post-processing may change the final extension or container.
- Prefer `--restrict-filenames` to reduce shell-unfriendly filenames.
- Use `--no-playlist` when the URL could resolve with playlist context.

## Supported workflows

- Inspect available formats before downloading when format choice matters.
- Download a single video locally.
- Extract audio to `mp3`.
- Optionally inspect the resulting local file with `ffprobe`.
- Load [references/youtube-downloader-commands.md](references/youtube-downloader-commands.md) for exact command patterns.

## Keep the workflow lean

- Prefer the smallest command that satisfies the request.
- Do not add custom wrappers, packaging steps, or unrelated media features.
