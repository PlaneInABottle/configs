# Video AI Projects - Technical Report

**Date:** March 2026

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Problem Space](#problem-space)
3. [Project 1: User Video Editor](#project-1-user-video-editor)
4. [Project 2: AI Video Generator](#project-2-ai-video-generator)
5. [Shared Infrastructure](#shared-infrastructure)
6. [Technical Considerations](#technical-considerations)

---

## Executive Summary

Two theoretical CLI/video projects were explored:

| Project | Description | Input | Output |
|---------|------------|-------|--------|
| **Project 1** | Video editor for user's raw footage | User's video clips | Edited video |
| **Project 2** | Video generator from topic/script | Topic or script | Generated video |

Both would theoretically use similar core infrastructure (FFmpeg, asset management) but serve different use cases.

---

## Problem Space

### Current Landscape

- **GUI Editors**: CapCut, Premiere, Final Cut - powerful but require manual editing
- **CLI Tools**: Mostly focused on download (yt-dlp), not editing
- **APIs**: Mux, Cloudinary - developer-focused, not end-user CLI

### What Could Be Good

- A CLI tool for users who prefer terminal or want automation
- An AI-assisted flow that reduces manual editing work
- Integration points with existing AI services (STT, TTS, vision)

---

## Project 1: User Video Editor

### Theoretical Concept

A CLI tool where users import their raw video clips, arrange them, add narration/audio, and export a polished video.

### Example Workflow

```bash
# Import clips
editor import video1.mp4 video2.mp4 video3.mp4

# Arrange order
editor arrange 1 3 2

# Add narration
editor narrate --text "Today I visited the mountains"

# Add music
editor music add background.mp3 --volume 0.3

# Add transition
editor transition 1-2 fade --duration 1

# Export
editor export output.mp4
```

### Implementation Considerations

| Aspect | Approach |
|--------|----------|
| **Core processing** | FFmpeg for all video operations |
| **CLI framework** | Python Click/Typer or Go Cobra |
| **State management** | JSON/YAML file to track timeline |
| **Audio** | Keep original, replace, or add narration |
| **Transitions** | FFmpeg filters (fade, dissolve) |

### What Would Be Good

- Simple, intuitive commands
- Preview capability if possible
- Support common formats (MP4, MOV, WebM)
- Progress indicators for rendering

---

## Project 2: AI Video Generator

### Theoretical Concept

A CLI tool that generates videos from a topic or script using stock assets, TTS narration, and background music.

### Example Workflow

```bash
# Generate from topic
generator --topic "Climate Change Impact" --style documentary

# Generate from script
generator --script script.txt --assets pexels

# Options
generator --topic "Taiwan News" --voice en-male-1 --music ambient
```

### Implementation Considerations

| Aspect | Approach |
|--------|----------|
| **Script** | User provides or AI generates |
| **Assets** | Stock APIs (Pexels, Unsplash) or AI generation |
| **Narration** | TTS service (ElevenLabs, Coqui) |
| **Timing** | Match image duration to audio |
| **Assembly** | FFmpeg image/video + audio → final |

### What Would Be Good

- Clear asset licensing handling
- Configurable voice options
- Support different video styles (documentary, news, social)
- Multiple aspect ratio outputs

---

## Shared Infrastructure

### Core Components

Both projects would benefit from shared modules:

```
┌─────────────────────────────────────┐
│           CLI Interface              │
├─────────────────────────────────────┤
│         Video Processor              │
│         (FFmpeg wrapper)            │
├─────────────────────────────────────┤
│         Asset Manager                │
├─────────────────────────────────────┤
│         Project State                │
└─────────────────────────────────────┘
```

### Key Technologies

| Component | Tool |
|-----------|------|
| Video processing | FFmpeg |
| Python wrappers | moviepy, ffmpeg-python |
| Asset APIs | Pexels, Unsplash |
| TTS | ElevenLabs, Coqui |
| STT | Whisper |

---

## Technical Considerations

### FFmpeg Capabilities

FFmpeg theoretically supports:
- Cutting, trimming, concatenating videos
- Adding audio tracks
- Transitions (fade, crossfade)
- Speed changes
- Resizing, cropping
- Text overlays
- Format conversion

### AI Integration Points

| Task | AI Service |
|------|-----------|
| Script generation | OpenAI, Gemini |
| Vision/image analysis | Gemini, GPT-4V |
| Speech-to-text | Whisper |
| Text-to-speech | ElevenLabs, Coqui |
| Stock assets | Pexels API |

### Local Alternatives

For offline use:
- **STT**: Whisper (local)
- **TTS**: Coqui, Piper
- **LLM**: Ollama
- **Video**: FFmpeg only

---

## Summary

Both projects are theoretically feasible using existing tools and APIs:

- **Project 1** would help users edit existing footage via CLI
- **Project 2** would help generate content from topics/scripts

The core shared component would be FFmpeg for video processing. AI services would handle narration, asset fetching, and optional script generation.

Further exploration would be needed to determine specific implementation details, API choices, and feature priorities.
