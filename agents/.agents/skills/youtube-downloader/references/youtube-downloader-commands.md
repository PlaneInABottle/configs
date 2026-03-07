# YouTube Downloader Commands

## Contents

- [Binary preflight](#binary-preflight)
- [Format inspection](#format-inspection)
- [Video download](#video-download)
- [Audio extraction to mp3](#audio-extraction-to-mp3)
- [Optional ffprobe inspection](#optional-ffprobe-inspection)

## Binary preflight

Run these checks before any download or extraction commands:

```bash
command -v yt-dlp
command -v ffmpeg
command -v ffprobe
```

Stop if any command is missing from `PATH`.

Some URLs may fail due to access restrictions, removal, age-gating, or geo-blocking; surface the extractor error rather than retrying with unrelated flags.

Use explicit placeholders in examples:

- `<youtube-watch-url>` = one standard YouTube watch URL
- `<output-file>` = the actual local file path produced by the prior yt-dlp command

## Format inspection

Inspect available formats before downloading when the user cares about quality, container, or size:

```bash
yt-dlp --no-playlist -F "<youtube-watch-url>"
```

Review the format list before choosing a custom `-f` selector.

## Video download

Download one video as mp4:

```bash
yt-dlp --no-playlist --restrict-filenames -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4 -o "%(title)s.%(ext)s" "<youtube-watch-url>"
```

- `--merge-output-format mp4` tells yt-dlp to remux the merged output into an mp4 container via FFmpeg.
- The `-f` selector prefers native mp4/m4a streams first (avoiding a transcode); falls back to best available if not present.
- Run from the intended destination directory.
- When merging/remuxing succeeds, yt-dlp will prefer an mp4 container; confirm the actual final filename/path after post-processing before passing it to follow-up commands.

## Audio extraction to mp3

Extract audio to `mp3`:

```bash
yt-dlp --no-playlist --restrict-filenames -f "bestaudio/best" -x --audio-format mp3 -o "%(title)s.%(ext)s" "<youtube-watch-url>"
```

- FFmpeg handles the extraction and conversion step.
- Confirm the actual resulting filename before using it in a later command.

## Optional ffprobe inspection

Inspect the resulting local file for container and stream details:

```bash
ffprobe -v error -show_format -show_streams "<output-file>"
```

Use after download or extraction with the actual file path created by yt-dlp.
