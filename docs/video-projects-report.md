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

---

## Existing Projects Research

### MoneyPrinterTurbo

A notable open-source project (52.8k stars) that implements the AI video generator concept:

| Aspect | Details |
|--------|---------|
| **Language** | Python (97.8%) |
| **Video editing** | MoviePy |
| **Web UI** | Streamlit |
| **API** | FastAPI |
| **LLM Providers** | OpenAI, DeepSeek, Moonshot, Azure, Gemini, Qwen, Ollama, etc. |
| **Stock assets** | Pexels API |
| **TTS** | Azure TTS, Edge TTS |
| **Subtitles** | Whisper, Edge TTS |

**Workflow:**
```
Topic → LLM (generate script) → Pexels (fetch assets) → TTS (voiceover) → MoviePy (assemble) → Subtitle → Output
```

**Features:**
- Web UI + API
- Multiple video sizes (9:16竖屏, 16:9横屏)
- Batch video generation
- Subtitle customization (font, color, position, stroke)
- Background music support
- Chinese/English support

### Similar Projects

| Project | Stars | Key Features |
|---------|-------|--------------|
| **AI-Youtube-Shorts-Generator** | 2.2k | GPT-4, extracts interesting sections from existing videos |
| **story-flicks** | 1.7k | AI story to video |
| **ScriptedYTShortsAI** | 40 | GPT-4, ElevenLabs, Fal AI (image gen) |
| **AI-Video-Production-Toolkit** | - | DALL-E 3, ElevenLabs, DeepSeek, synchronized captions |
| **AI-Story-To-Movie** | - | Gemini, Imagen 3, Google Veo (video generation) |

### Common Implementation Pattern

```
Topic → LLM (script/scene breakdown) → Assets (stock/AI) → TTS (voiceover) → MoviePy (assembly) → Subtitle → Music → Output
```

### Key Technologies Used

| Component | Common Tools |
|-----------|-------------|
| Video processing | MoviePy, FFmpeg |
| Script generation | OpenAI GPT, Gemini, DeepSeek |
| Image generation | DALL-E, Flux, Stable Diffusion |
| Stock assets | Pexels API, Pixabay API |
| TTS | ElevenLabs, Azure TTS, Edge TTS |
| STT/Subtitles | Whisper, WhisperX |
| Web UI | Streamlit |
| API | FastAPI |

---

## Summary

Both projects are theoretically feasible using existing tools and APIs:

- **Project 1** would help users edit existing footage via CLI
- **Project 2** would help generate content from topics/scripts

The core shared component would be FFmpeg for video processing. AI services would handle narration, asset fetching, and optional script generation.

MoneyPrinterTurbo demonstrates a working implementation of Project 2 with:
- Proven architecture (LLM → Assets → TTS → MoviePy → Output)
- Multiple LLM provider support
- Web UI + API interfaces

Further exploration would be needed to determine specific implementation details, API choices, and feature priorities.
