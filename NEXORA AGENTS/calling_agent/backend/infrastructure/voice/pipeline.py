from __future__ import annotations

from typing import AsyncIterator, Optional

from backend.infrastructure.voice.stt.base import STTProvider
from backend.infrastructure.voice.tts.base import TTSProvider
from backend.infrastructure.voice.vad.base import VADProvider


class VoicePipeline:
    def __init__(self, stt: STTProvider, tts: TTSProvider, vad: VADProvider) -> None:
        self._stt = stt
        self._tts = tts
        self._vad = vad
        self._silence_frames = 0
        self._max_silence_frames = 20
        self._noise_threshold = 0.02

    def _suppress_noise(self, audio_frame: bytes) -> bytes:
        import struct
        samples = struct.unpack_from(f"<{len(audio_frame) // 2}h", audio_frame[:len(audio_frame) - len(audio_frame) % 2])
        threshold = int(self._noise_threshold * 32768)
        suppressed = [max(-threshold, min(threshold, s)) for s in samples]
        return struct.pack(f"<{len(suppressed)}h", *suppressed)

    async def process_input(self, audio_frame: bytes) -> Optional[str]:
        is_speech = self._vad.is_speech(audio_frame)
        is_silence = self._vad.detect_silence(audio_frame)

        if is_silence:
            self._silence_frames += 1
        else:
            self._silence_frames = 0

        if not is_speech:
            return None

        cleaned = self._suppress_noise(audio_frame)
        text = await self._stt.transcribe(cleaned)
        return text if text.strip() else None

    async def generate_output(self, text: str, emotion: str = "neutral") -> AsyncIterator[bytes]:
        await self._tts.set_emotion(emotion)
        async for chunk in self._tts.synthesize_streaming(text):
            yield chunk

    async def process_stream(self, audio_stream: AsyncIterator[bytes]) -> AsyncIterator[dict]:
        audio_buffer = bytearray()
        frame_size = self._vad.get_frame_size()
        is_speaking = False
        utterance_buffer = bytearray()

        async for chunk in audio_stream:
            audio_buffer.extend(chunk)
            while len(audio_buffer) >= frame_size:
                frame = bytes(audio_buffer[:frame_size])
                audio_buffer = audio_buffer[frame_size:]

                is_speech = self._vad.is_speech(frame)

                if is_speech:
                    is_speaking = True
                    utterance_buffer.extend(frame)
                    self._silence_frames = 0
                elif is_speaking:
                    self._silence_frames += 1
                    if self._silence_frames >= self._max_silence_frames:
                        text = await self._stt.transcribe(bytes(utterance_buffer))
                        if text.strip():
                            yield {"type": "transcript", "text": text.strip(), "is_final": True}
                        utterance_buffer.clear()
                        is_speaking = False
                        self._silence_frames = 0

        if utterance_buffer:
            text = await self._stt.transcribe(bytes(utterance_buffer))
            if text.strip():
                yield {"type": "transcript", "text": text.strip(), "is_final": True}

    def detect_interruption(self, audio_frame: bytes, is_speaking: bool) -> bool:
        if not is_speaking:
            return False
        is_speech = self._vad.is_speech(audio_frame)
        is_loud = not self._vad.detect_silence(audio_frame, threshold=0.05)
        return is_speech and is_loud
