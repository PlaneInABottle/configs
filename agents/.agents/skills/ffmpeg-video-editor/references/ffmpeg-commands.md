# FFmpeg Video Editor Commands

Comprehensive command reference for CLI video editing.

## Contents

- [Preflight](#preflight)
- [Basic Operations](#basic-operations)
- [Cuts & Trimming](#cuts--trimming)
- [Video Effects](#video-effects)
- [Transitions](#transitions)
- [Zoom & Pan](#zoom--pan)
- [Audio](#audio)
- [Color Correction](#color-correction)
- [Text Overlays](#text-overlays)
- [Format & Codec](#format--codec)
- [Advanced](#advanced)

---

## Preflight

Verify FFmpeg is installed before running any commands:

```bash
command -v ffmpeg
command -v ffprobe
```

Inspect video properties:

```bash
ffprobe -v error -show_format -show_streams "input.mp4"
```

---

## Basic Operations

### Join/Merge Multiple Videos

```bash
# Concatenate videos (requires same codec/resolution)
ffmpeg -f concat -safe 0 -i filelist.txt -c copy output.mp4

# filelist.txt format:
# file 'video1.mp4'
# file 'video2.mp4'
# file 'video3.mp4'
```

### Split Video

```bash
# Split into chunks of 60 seconds
ffmpeg -i input.mp4 -c copy -f segment -segment_time 60 -reset_timestamps 1 output_%03d.mp4
```

### Extract Frames

```bash
# Extract all frames as images
ffmpeg -i input.mp4 frame_%04d.png

# Extract one frame at specific time
ffmpeg -i input.mp4 -ss 00:00:10.000 -vframes 1 frame.jpg
```

### Create Video from Images

```bash
# Images to video (30 fps)
ffmpeg -framerate 30 -i frame_%04d.png -c:v libx264 -pix_fmt yuv420p output.mp4

# Images to video with duration per image
ffmpeg -framerate 1 -loop 1 -duration 3 -i image1.png -framerate 1 -loop 1 -duration 2 -i image2.png -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0" output.mp4
```

---

## Cuts & Trimming

### Quick Cut (Re-mux only, no re-encode)

```bash
# Cut from 10s to 30s (fast, no re-encode)
ffmpeg -ss 00:00:10 -to 00:00:30 -i input.mp4 -c copy output.mp4

# Cut with re-encoding (more accurate)
ffmpeg -ss 00:00:10 -to 00:00:30 -i input.mp4 -c:v libx264 -c:a aac output.mp4
```

### Trim to Duration

```bash
# Keep first 30 seconds
ffmpeg -i input.mp4 -t 30 -c copy output.mp4

# Start at 10s, keep 20 seconds
ffmpeg -ss 10 -i input.mp4 -t 20 -c copy output.mp4
```

### Cut at Keyframes (Fast seeking)

```bash
# Cuts only at keyframes (faster but less precise)
ffmpeg -i input.mp4 -c copy -ss 00:00:10 -to 00:00:30 output.mp4
```

---

## Video Effects

### Brightness, Contrast, Saturation

```bash
# Adjust brightness (0.1 = brighter, -0.1 = darker)
ffmpeg -i input.mp4 -vf "eq=brightness=0.1" output.mp4

# Adjust contrast (1.2 = more contrast)
ffmpeg -i input.mp4 -vf "eq=contrast=1.2" output.mp4

# Adjust saturation (0 = grayscale, 2 = vivid)
ffmpeg -i input.mp4 -vf "eq=saturation=1.5" output.mp4

# All in one
ffmpeg -i input.mp4 -vf "eq=brightness=0.05:contrast=1.1:saturation=1.3" output.mp4
```

### Blur & Sharpen

```bash
# Gaussian blur
ffmpeg -i input.mp4 -vf "gaussian=st=5:mx=10" output.mp4

# Box blur
ffmpeg -i input.mp4 -vf "boxblur=2:1" output.mp4

# Sharpen
ffmpeg -i input.mp4 -vf "unsharp=5:5:1.0:5:5:0.0" output.mp4
```

### Denoise

```bash
# Temporal denoise (slow but effective)
ffmpeg -i input.mp4 -vf "hqdn3d=4:3:6:4.5" output.mp4

# Fast denoise
ffmpeg -i input.mp4 -vf "nlmeans=s=7:p=3:r=1" output.mp4
```

### Rotate & Flip

```bash
# Rotate 90 degrees clockwise
ffmpeg -i input.mp4 -vf "rotate=PI/2" output.mp4

# Rotate 90 degrees counter-clockwise
ffmpeg -i input.mp4 -vf "rotate=-PI/2" output.mp4

# Flip horizontal
ffmpeg -i input.mp4 -vf "hflip" output.mp4

# Flip vertical
ffmpeg -i input.mp4 -vf "vflip" output.mp4

# Auto-orient (based on metadata)
ffmpeg -i input.mp4 -c copy -metadata:s:v rotate=0 output.mp4
```

### Crop & Pad

```bash
# Crop center 50%
ffmpeg -i input.mp4 -vf "crop=iw/2:ih/2:iw/4:ih/4" output.mp4

# Crop specific (width:height:x:y)
ffmpeg -i input.mp4 -vf "crop=1280:720:100:50" output.mp4

# Add black padding (letterbox)
ffmpeg -i input.mp4 -vf "pad=1920:1080:(ow-iw)/2:(oh-ih)/2" output.mp4

# Crop + pad to target resolution
ffmpeg -i input.mp4 -vf "crop=iw:iw*9/16,scale=1080:1920,pad=1080:1920:0:0" output.mp4
```

### Resize

```bash
# Scale to 720p
ffmpeg -i input.mp4 -vf "scale=-2:720" output.mp4

# Scale to 1080p (width auto)
ffmpeg -i input.mp4 -vf "scale=-2:1080" output.mp4

# Scale to specific resolution
ffmpeg -i input.mp4 -vf "scale=1920:1080" output.mp4

# Scale to 50%
ffmpeg -i input.mp4 -vf "scale=iw/2:ih/2" output.mp4
```

### Speed Change

```bash
# Double speed (0.5x)
ffmpeg -i input.mp4 -filter:v "setpts=0.5*PTS" -filter:a "atempo=2.0" output.mp4

# Half speed (2x slower)
ffmpeg -i input.mp4 -filter:v "setpts=2.0*PTS" -filter:a "atempo=0.5" output.mp4

# 1.5x speed
ffmpeg -i input.mp4 -filter:v "setpts=0.666*PTS" -filter:a "atempo=1.5" output.mp4
```

### Reverse

```bash
# Reverse video
ffmpeg -i input.mp4 -vf "reverse" output.mp4

# Reverse audio
ffmpeg -i input.mp4 -af "areverse" output.mp4

# Reverse both
ffmpeg -i input.mp4 -vf "reverse" -af "areverse" output.mp4
```

---

## Transitions

### Fade In/Out

```bash
# Fade in (first 2 seconds)
ffmpeg -i input.mp4 -vf "fade=t=in:st=0:d=2" output.mp4

# Fade out (last 2 seconds)
ffmpeg -i input.mp4 -vf "fade=t=out:st=8:d=2" output.mp4

# Fade in + fade out
ffmpeg -i input.mp4 -vf "fade=t=in:st=0:d=2,fade=t=out:st=8:d=2" output.mp4

# Fade to black (2 seconds at end)
ffmpeg -i input.mp4 -vf "fade=t=out:st=8:d=2:color=black" output.mp4
```

### Crossfade (Transition between 2 videos)

```bash
# Crossfade from video1 to video2 (1 second transition)
ffmpeg -i video1.mp4 -i video2.mp4 -filter_complex "[0:v][1:v]xfade=transition=fade:duration=1:offset=4[v];[0:a][1:a]acrossfade=d=1[a]" -map "[v]" -map "[a]" output.mp4

# Crossfade with different transition types
# fade, dissolve, wipeleft, wiperight, wipeup, wipedown, slideleft, slideright, slideup, slidedown, circlecrop, rectcrop, distance, fadeblack, fadewhite, radial, smoothleft, smoothright, smoothup, smoothdown, pixelize, diagtl, diagtr, diagbl, diagbr, hlslice, hrslice, vuslice, vdslice, zoomin
ffmpeg -i video1.mp4 -i video2.mp4 -filter_complex "[0:v][1:v]xfade=transition=dissolve:duration=1:offset=4[v];[0:a][1:a]acrossfade=d=1[a]" -map "[v]" -map "[a]" output.mp4
```

### Dissolve

```bash
# Dissolve transition (similar to crossfade)
ffmpeg -i video1.mp4 -i video2.mp4 -filter_complex "[0:v][1:v]xfade=transition=dissolve:duration=1:offset=4[v]" -map "[v]" -c:v libx264 -pix_fmt yuv420p output.mp4
```

---

## Zoom & Pan

### Zoom (Scale)

```bash
# Zoom in 2x
ffmpeg -i input.mp4 -vf "scale=2*iw:2*ih" output.mp4

# Zoom to 150%
ffmpeg -i input.mp4 -vf "scale=1.5*iw:1.5*ih" output.mp4
```

### Ken Burns Effect (Slow Zoom + Pan)

```bash
# Slow zoom in + pan right
ffmpeg -i input.mp4 -vf "zoompan=z='1+0.1*t':x='min(iw/2-w/2,0+50*t)':y='ih/2-h/2':d=10:s=1920x1080" output.mp4

# Slow zoom out + pan left
ffmpeg -i input.mp4 -vf "zoompan=z='1.5-0.05*t':x='max(0,iw-w-50*t)':y='ih/2-h/2':d=10:s=1920x1080" output.mp4

# Zoom in to center (2x over 5 seconds)
ffmpeg -i input.mp4 -vf "zoompan=z='min(zoom+0.001,2)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1920x1080" output.mp4
```

### Pan (Move)

```bash
# Pan left to right
ffmpeg -i input.mp4 -vf "zoompan=x='min(iw/2-w/2,0+50*t)':y='ih/2-h/2':z='1':d=1:s=1920x1080" output.mp4
```

### Close-up Effect

```bash
# Close-up (crop + zoom)
ffmpeg -i input.mp4 -vf "crop=iw*0.5:ih*0.5:iw*0.25:ih*0.25,scale=iw*2:ih*2" output.mp4

# Dynamic close-up (slow zoom in)
ffmpeg -i input.mp4 -vf "crop=iw*0.7:ih*0.7,scale=1.4*iw:1.4*ih" output.mp4

# Track close-up (follows a point)
ffmpeg -i input.mp4 -vf "zoompan=x='iw/2-w/2+100*sin(t)':y='ih/2-h/2+50*cos(t)':z='1+0.1*t':d=10:s=1920x1080" output.mp4
```

---

## Audio

### Add Audio to Video

```bash
# Replace audio (or add if none)
ffmpeg -i video.mp4 -i audio.mp3 -c:v copy -c:a aac -shortest output.mp4

# Mix new audio with original
ffmpeg -i video.mp4 -i audio.mp3 -filter_complex "[0:a][1:a]amix=inputs=2:duration=first[a]" -map 0:v -map "[a]" output.mp4
```

### Volume Adjustment

```bash
# Double volume
ffmpeg -i input.mp4 -af "volume=2.0" output.mp4

# Half volume
ffmpeg -i input.mp4 -af "volume=0.5" output.mp4

# Mute video (keep only audio)
ffmpeg -i input.mp4 -vn -c:a aac output.mp4
```

### Audio Fade In/Out

```bash
# Fade in (first 2 seconds)
ffmpeg -i input.mp4 -af "afade=t=in:st=0:d=2" output.mp4

# Fade out (last 2 seconds - calculate duration)
ffmpeg -i input.mp4 -af "afade=t=out:st=8:d=2" output.mp4
```

### Extract/Remove Audio

```bash
# Extract audio to MP3
ffmpeg -i input.mp4 -vn -c:a libmp3lame -q:a 2 output.mp3

# Extract audio to WAV
ffmpeg -i input.mp4 -vn -c:a pcm_s16le output.wav

# Remove audio from video
ffmpeg -i input.mp4 -c:v copy -an output.mp4
```

### Audio Speed/Pitch

```bash
# Change speed without pitch
ffmpeg -i input.mp4 -af "atempo=1.5" output.mp4

# Change speed with pitch preservation
ffmpeg -i input.mp4 -af "asetrate=44100*1.5,aresample=44100" output.mp4
```

---

## Color Correction

### Hue Adjustment

```bash
# Rotate hue (0-360 degrees)
ffmpeg -i input.mp4 -vf "hue=h=90" output.mp4

# Adjust hue + saturation
ffmpeg -i input.mp4 -vf "hue=h=30:s=1.5" output.mp4
```

### Temperature (Warm/Cool)

```bash
# Warmer (more yellow/red)
ffmpeg -i input.mp4 -vf "eq=saturation=1.2:gamma=1.2:contrast=1.1" output.mp4

# Cooler (more blue)
ffmpeg -i input.mp4 -vf "colortemperature=temperature=6500" output.mp4
```

### Color Grading (LUT)

```bash
# Apply LUT (if you have a .cube file)
ffmpeg -i input.mp4 -vf "lut3d=cube=grading.cube" output.mp4
```

### Black & White / Sepia

```bash
# Black and white
ffmpeg -i input.mp4 -vf "hue=s=0" output.mp4

# Sepia tone
ffmpeg -i input.mp4 -vf "colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131" output.mp4

# High contrast B&W
ffmpeg -i input.mp4 -vf "hue=s=0,eq=contrast=1.5" output.mp4
```

### Vignette

```bash
# Add vignette
ffmpeg -i input.mp4 -vf "vignette=angle=PI/5" output.mp4

# Strong vignette
ffmpeg -i input.mp4 -vf "vignette=angle=PI/8:mode=forward" output.mp4
```

---

## Text Overlays

### Simple Text

```bash
# Add text overlay
ffmpeg -i input.mp4 -vf "drawtext=text='Hello World':fontsize=48:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2" output.mp4

# Text with font
ffmpeg -i input.mp4 -vf "drawtext=text='Hello':fontsize=48:fontcolor=white:fontpath=/Library/Fonts/Arial.ttf:x=100:y=100" output.mp4
```

### Text with Background

```bash
# Text with shadow
ffmpeg -i input.mp4 -vf "drawtext=text='Hello':fontsize=48:fontcolor=white:shadowx=2:shadowy=2:x=100:y=100" output.mp4

# Text with box
ffmpeg -i input.mp4 -vf "drawtext=text='Hello':fontsize=48:fontcolor=white:box=1:boxcolor=black@0.5:boxborderw=10:x=100:y=100" output.mp4
```

### Animated Text

```bash
# Text fade in (requires complex filter)
ffmpeg -i input.mp4 -vf "drawtext=text='Hello':fontsize=48:fontcolor=white:alpha='if(lt(t,2),0,if(lt(t,3),(t-2)/1,1))':x=100:y=100" output.mp4
```

---

## Format & Codec

### Common Codecs

```bash
# H.264 video + AAC audio (most compatible)
ffmpeg -i input.mp4 -c:v libx264 -c:a aac output.mp4

# H.265/HEVC (better compression)
ffmpeg -i input.mp4 -c:v libx265 -c:a aac output.mp4

# VP9 (web-friendly, royalty-free)
ffmpeg -i input.mp4 -c:v libvpx-vp9 -c:a libopus output.webm

# ProRes (professional)
ffmpeg -i input.mp4 -c:v prores_ks -profile:v 3 -c:a pcm_s16le output.mov
```

### Presets (Compression Speed)

```bash
# ultrafast, superfast, veryfast, faster, fast, medium (default), slow, slower, veryslow
ffmpeg -i input.mp4 -c:v libx264 -preset slow -crf 23 output.mp4
```

### Quality (CRF)

```bash
# Lower CRF = higher quality (0-51, 18-28 is good range)
ffmpeg -i input.mp4 -c:v libx264 -crf 18 output.mp4

# Higher compression
ffmpeg -i input.mp4 -c:v libx264 -crf 28 output.mp4
```

### Convert Format

```bash
# MP4 to WebM
ffmpeg -i input.mp4 -c:v libvpx-vp9 -c:a libopus output.webm

# MP4 to MOV
ffmpeg -i input.mp4 -c:v copy -c:a copy output.mov

# MP4 to GIF
ffmpeg -i input.mp4 -vf "fps=15,scale=320:-1:flags=lanczos" output.gif

# GIF to MP4
ffmpeg -i input.gif -movflags faststart -pix_fmt yuv420p output.mp4
```

### Change Resolution

```bash
# To 720p
ffmpeg -i input.mp4 -vf "scale=-2:720" -c:a copy output.mp4

# To 1080p
ffmpeg -i input.mp4 -vf "scale=-2:1080" -c:a copy output.mp4

# To 4K
ffmpeg -i input.mp4 -vf "scale=-2:2160" -c:a copy output.mp4
```

---

## Advanced

### Multiple Filters Chain

```bash
# Chain filters (applied in order)
ffmpeg -i input.mp4 -vf "eq=brightness=0.1,eq=contrast=1.2,fade=t=in:st=0:d=2" output.mp4
```

### Complex Filter Graph

```bash
# Split to multiple outputs
ffmpeg -i input.mp4 -filter_complex "[0:v]split=2[v1][v2]" -map "[v1]" output1.mp4 -map "[v2]" output2.mp4
```

### Overlay (Picture-in-Picture)

```bash
# Overlay logo/watermark
ffmpeg -i main.mp4 -i logo.png -filter_complex "[1:v]scale=100:100[logo];[0:v][logo]overlay=10:10" output.mp4

# Picture-in-picture (small video on top-right)
ffmpeg -i main.mp4 -i small.mp4 -filter_complex "[1:v]scale=320:180[small];[0:v][small]overlay=main_w-330:10" output.mp4
```

### Stabilization

```bash
# Analyze first (two-pass)
ffmpeg -i input.mp4 -vf vidstabdetect=shakiness=5:accuracy=15 -f null -

# Apply stabilization
ffmpeg -i input.mp4 -vf unsharp=5:5:1.0,vidstabtransform=input=transforms.trf:optalgo=smooth:crop=black:zoom=0:interpol=linear output.mp4
```

### Chromakey (Green Screen)

```bash
# Remove green screen
ffmpeg -i input.mp4 -vf "chromakey=0x00ff00:0.3:0.1" output.mp4

# Custom color key
ffmpeg -i input.mp4 -vf "chromakey=0x2d5d38:0.4:0.1" output.mp4
```

### Slow Motion with Interpolation

```bash
# Interpolate frames for smooth slow-mo (requires minterpolate)
ffmpeg -i input.mp4 -filter:v "minterpolate=fps=60:mi_mode=mci:me_mode=bidir" -r 60 output.mp4
```

### Concatenation with Transitions

```bash
# File list for concat
# file 'video1.mp4'
# file 'video2.mp4'
# file 'video3.mp4'

ffmpeg -f concat -safe 0 -i filelist.txt -c copy output.mp4

# With re-encoding
ffmpeg -f concat -safe 0 -i filelist.txt -c:v libx264 -c:a aac output.mp4
```

### Batch Processing (All files in directory)

```bash
# Process all .mp4 files (bash)
for f in *.mp4; do ffmpeg -i "$f" -vf "eq=brightness=0.1" "bright_$f"; done
```

### Progress & Stats

```bash
# Show progress
ffmpeg -i input.mp4 -progress progress.txt output.mp4

# Stats only (no output)
ffmpeg -i input.mp4 -f null -
```

---

## Quick Reference

| Operation | Command Flag |
|-----------|---------------|
| Cut | `-ss start -t duration` |
| Scale | `scale=w:h` |
| Crop | `crop=w:h:x:y` |
| Fade | `fade=t=in/out:st=time:d=duration` |
| Volume | `volume=2.0` |
| Brightness | `eq=brightness=0.1` |
| Contrast | `eq=contrast=1.2` |
| Rotate | `rotate=PI/2` |
| Speed | `setpts=N/PTS` (video), `atempo=N` (audio) |
| Copy codec | `-c copy` |
