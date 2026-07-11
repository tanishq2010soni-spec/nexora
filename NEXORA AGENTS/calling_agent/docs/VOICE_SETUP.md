# Voice Pipeline Setup

## Overview

The voice pipeline handles real-time audio processing for phone calls. It consists of three main components: Speech-to-Text (STT), Text-to-Speech (TTS), and Voice Activity Detection (VAD).

## STT Providers

### Whisper (Local)

Open-source speech recognition model from OpenAI that runs locally.

**Installation:**
```bash
pip install openai-whisper
```

**Configuration:**
```python
stt = STTFactory.create("whisper", {
    "model": "base",       # Model size: tiny, base, small, medium, large, large-v2, large-v3
    "language": "en",      # Language code
})
```

**Available Models:**

| Model | Size | RAM | Speed | Accuracy |
|-------|------|-----|-------|----------|
| tiny | ~75MB | ~1GB | Fastest | Low |
| base | ~150MB | ~1GB | Fast | Medium |
| small | ~500MB | ~2GB | Medium | Good |
| medium | ~1.5GB | ~5GB | Slow | Better |
| large | ~3GB | ~10GB | Slowest | Best |

**Notes:**
- Runs fully offline, no data leaves your server
- Higher accuracy models require more RAM and GPU
- Supports 100+ languages
- Streaming mode buffers audio in 32000-byte chunks

### Deepgram (Cloud)

Cloud-based speech recognition API with real-time streaming.

**Installation:**
```bash
pip install httpx
```

**Configuration:**
```python
stt = STTFactory.create("deepgram", {
    "api_key": "your_deepgram_api_key",
})
```

**Available Models:** nova-2, nova-2-general, whisper, base, enhanced

**Notes:**
- Requires internet connection
- Real-time streaming support
- Higher accuracy than Whisper for most cases
- Pay-per-use pricing

## TTS Providers

### pyttsx3 (Local)

Offline text-to-speech engine that uses system TTS capabilities.

**Installation:**
```bash
pip install pyttsx3
```

**Platform-specific dependencies:**
- **Linux**: `sudo apt install espeak espeak-data libespeak1`
- **macOS**: Built-in voices available
- **Windows**: Built-in SAPI5 voices available

**Configuration:**
```python
tts = TTSFactory.create("pyttsx3", {
    "voice": "default",    # Voice name or "default"
    "speed": 1.0,          # Speech rate multiplier
    "pitch": 1.0,          # Voice pitch multiplier
})
```

**Notes:**
- Fully offline
- Voice quality varies by platform
- Emotion support via rate adjustment:
  - neutral: 1.0x speed
  - happy: 1.2x speed
  - serious: 0.85x speed
  - sympathetic: 0.9x speed
  - urgent: 1.3x speed
  - energetic: 1.15x speed

### ElevenLabs (Cloud)

Cloud-based TTS with natural-sounding voices and emotion control.

**Installation:**
```bash
pip install httpx
```

**Configuration:**
```python
tts = TTSFactory.create("elevenlabs", {
    "api_key": "your_elevenlabs_api_key",
    "voice_id": "default",  # Voice ID or "default" (Rachel)
})
```

**Notes:**
- Requires internet connection
- Natural voice quality
- Emotion control via stability parameter:
  - neutral: 0.5
  - happy: 0.3
  - serious: 0.7
  - sympathetic: 0.6
  - urgent: 0.2
  - energetic: 0.25

## VAD Providers

### WebRTC VAD (Local)

Browser-compatible VAD implementation, lightweight and fast.

**Installation:**
```bash
pip install webrtcvad
```

**Configuration:**
```python
vad = VADFactory.create("webrtc", {
    "mode": 1,        # Aggressiveness mode 0-3 (0=least aggressive, 3=most)
    "frame_ms": 30,   # Frame duration in ms (10, 20, or 30)
})
```

**Frame sizes (at 16kHz sample rate):**
- 10ms: 320 bytes
- 20ms: 640 bytes
- 30ms: 960 bytes

**Modes:**
- 0: Least aggressive, filters only silence
- 1: Moderate filtering (default)
- 2: Aggressive filtering
- 3: Most aggressive, filters out more non-speech

### Silero VAD (Local)

Deep learning-based VAD, more accurate in noisy environments.

**Installation:**
```bash
pip install torch numpy
```

**Configuration:**
```python
vad = VADFactory.create("silero", {
    "threshold": 0.5,   # Speech probability threshold (0.0-1.0)
    "frame_ms": 30,     # Frame duration in ms
})
```

**Notes:**
- Requires PyTorch (can be large)
- Better accuracy than WebRTC in noisy conditions
- Maintains internal state between frames for context
- Falls back to silence detection if model is unavailable

## Noise Suppression

The voice pipeline includes built-in noise suppression that applies a soft threshold to audio samples before STT processing. This reduces background noise and improves transcription accuracy.

Configuration through VoiceSettings entity:
```python
{
    "noise_suppression": True,   # Enable/disable noise suppression
    "echo_cancellation": True,   # Enable/disable echo cancellation
}
```

## Sample Rates and Audio Formats

### Supported Sample Rates

- **STT**: 16kHz (Whisper accepts 16kHz, Deepgram accepts various rates)
- **TTS**: Output is typically 16kHz or 22kHz depending on provider
- **VAD**: 16kHz (required by WebRTC VAD)
- **Phone Providers**: 8kHz (PCMU/PCMA), 16kHz (wideband)

### Audio Format

All internal audio processing uses:
- Format: 16-bit PCM
- Sample Rate: 16kHz (mono)
- Byte Order: Little-endian, signed

## Testing Voice Pipeline

### Quick Test

```python
import asyncio
from backend.infrastructure.voice.pipeline import VoicePipeline
from backend.infrastructure.voice.stt.factory import STTFactory
from backend.infrastructure.voice.tts.factory import TTSFactory
from backend.infrastructure.voice.vad.factory import VADFactory

async def test_pipeline():
    stt = STTFactory.create("whisper", {"model": "base"})
    tts = TTSFactory.create("pyttsx3", {"voice": "default"})
    vad = VADFactory.create("webrtc", {"mode": 1})

    pipeline = VoicePipeline(stt=stt, tts=tts, vad=vad)

    # Test input processing
    result = await pipeline.process_input(b"\x00" * 960)
    print(f"Input result: {result}")

    # Test output generation
    async for chunk in pipeline.generate_output("Hello, world!"):
        print(f"Output chunk: {len(chunk)} bytes")

asyncio.run(test_pipeline())
```

### VAD Test

```python
from backend.infrastructure.voice.vad.factory import VADFactory

vad = VADFactory.create("webrtc", {"mode": 1, "frame_ms": 30})
frame_size = vad.get_frame_size()  # 960 bytes

# Test silence detection
silence = b"\x00" * frame_size
print(f"Silence detected: {vad.detect_silence(silence)}")  # True

# Test speech detection (random noise)
import random
noise = bytes([random.randint(0, 255) for _ in range(frame_size)])
print(f"Speech detected: {vad.is_speech(noise)}")  # Possibly True
```

### STT Test

```python
import asyncio
from backend.infrastructure.voice.stt.factory import STTFactory

async def test_stt():
    stt = STTFactory.create("deepgram", {"api_key": "your_key"})
    models = await stt.get_available_models()
    print(f"Available models: {models}")

    # Transcribe an audio file
    text = await stt.transcribe_file("test.wav")
    print(f"Transcription: {text}")

asyncio.run(test_stt())
```

### TTS Test

```python
import asyncio
from backend.infrastructure.voice.tts.factory import TTSFactory

async def test_tts():
    tts = TTSFactory.create("elevenlabs", {"api_key": "your_key"})
    audio = await tts.synthesize("Hello, how can I help you?")
    print(f"Generated {len(audio)} bytes of audio")

    voices = await tts.get_available_voices()
    print(f"Available voices: {voices}")

asyncio.run(test_tts())
```
