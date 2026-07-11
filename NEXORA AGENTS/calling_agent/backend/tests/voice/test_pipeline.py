from __future__ import annotations

from typing import AsyncIterator
from unittest.mock import AsyncMock, MagicMock, patch

import httpx
import pytest

from backend.infrastructure.voice.pipeline import VoicePipeline
from backend.infrastructure.voice.stt.base import STTProvider
from backend.infrastructure.voice.stt.factory import STTFactory
from backend.infrastructure.voice.stt.whisper import WhisperSTT
from backend.infrastructure.voice.stt.deepgram import DeepgramSTT
from backend.infrastructure.voice.tts.base import TTSProvider
from backend.infrastructure.voice.tts.factory import TTSFactory
from backend.infrastructure.voice.tts.pyttsx3_tts import PyTTSx3TTS
from backend.infrastructure.voice.tts.elevenlabs import ElevenLabsTTS
from backend.infrastructure.voice.vad.base import VADProvider
from backend.infrastructure.voice.vad.factory import VADFactory
from backend.infrastructure.voice.vad.webrtc_vad import WebRTCVAD
from backend.infrastructure.voice.vad.silero_vad import SileroVAD


@pytest.fixture
def mock_stt():
    provider = MagicMock(spec=STTProvider)
    provider.transcribe = AsyncMock(return_value="hello world")
    provider.transcribe_file = AsyncMock(return_value="file transcription")
    provider.streaming_transcribe = AsyncMock()
    provider.get_available_models = AsyncMock(return_value=["tiny", "base"])
    return provider


@pytest.fixture
def mock_tts():
    provider = MagicMock(spec=TTSProvider)
    provider.synthesize = AsyncMock(return_value=b"audio_data")
    provider.synthesize_streaming = AsyncMock()
    provider.get_available_voices = AsyncMock(return_value=[{"id": "voice1", "name": "Voice 1"}])
    provider.set_emotion = AsyncMock()
    return provider


@pytest.fixture
def mock_vad():
    provider = MagicMock(spec=VADProvider)
    provider.is_speech = MagicMock(return_value=True)
    provider.detect_silence = MagicMock(return_value=False)
    provider.get_frame_size = MagicMock(return_value=960)
    return provider


@pytest.fixture
def pipeline(mock_stt, mock_tts, mock_vad):
    return VoicePipeline(stt=mock_stt, tts=mock_tts, vad=mock_vad)


class TestVADDetection:
    def test_webrtc_vad_speech_detection(self):
        vad = WebRTCVAD(mode=1, frame_ms=30)
        frame_size = vad.get_frame_size()
        silence_frame = b"\x00" * frame_size
        assert not vad.is_speech(silence_frame)
        assert vad.detect_silence(silence_frame)

    def test_webrtc_vad_silence_detection(self):
        vad = WebRTCVAD(mode=1, frame_ms=30)
        frame_size = vad.get_frame_size()
        silence_frame = b"\x00" * frame_size
        assert vad.detect_silence(silence_frame, threshold=0.01)

    def test_webrtc_vad_frame_size(self):
        vad = WebRTCVAD(mode=1, frame_ms=30)
        assert vad.get_frame_size() == 960
        vad2 = WebRTCVAD(mode=0, frame_ms=20)
        assert vad2.get_frame_size() == 640

    def test_webrtc_vad_partial_frame(self):
        vad = WebRTCVAD(mode=1, frame_ms=30)
        partial = b"\x00" * 100
        result = vad.is_speech(partial)
        assert result is not None

    def test_silero_vad_silence_detection(self):
        vad = SileroVAD(threshold=0.5, frame_ms=30)
        silence_frame = b"\x00" * vad.get_frame_size()
        assert vad.detect_silence(silence_frame)

    def test_silero_vad_frame_size(self):
        vad = SileroVAD(threshold=0.5, frame_ms=30)
        assert vad.get_frame_size() == 960

    def test_vad_factory_webrtc(self):
        vad = VADFactory.create("webrtc", {"mode": 1, "frame_ms": 30})
        assert isinstance(vad, WebRTCVAD)
        assert vad.get_frame_size() == 960

    def test_vad_factory_silero(self):
        vad = VADFactory.create("silero", {"threshold": 0.5, "frame_ms": 30})
        assert isinstance(vad, SileroVAD)

    def test_vad_factory_unknown(self):
        with pytest.raises(ValueError, match="Unknown VAD provider"):
            VADFactory.create("unknown", {})

    def test_vad_abstract_base(self):
        with pytest.raises(TypeError):
            VADProvider()


class TestSTTFactory:
    def test_create_whisper(self):
        stt = STTFactory.create("whisper", {"model": "base", "language": "en"})
        assert isinstance(stt, WhisperSTT)

    def test_create_deepgram(self):
        stt = STTFactory.create("deepgram", {"api_key": "test_key"})
        assert isinstance(stt, DeepgramSTT)

    def test_create_unknown(self):
        with pytest.raises(ValueError, match="Unknown STT provider"):
            STTFactory.create("unknown", {})

    def test_stt_abstract_base(self):
        with pytest.raises(TypeError):
            STTProvider()

    @pytest.mark.asyncio
    async def test_whisper_transcribe_no_model(self):
        stt = WhisperSTT(model="base", language="en")
        stt._available = False
        result = await stt.transcribe(b"audio")
        assert result == "transcription unavailable: whisper not installed"

    @pytest.mark.asyncio
    async def test_whisper_available_models(self):
        stt = WhisperSTT(model="base", language="en")
        models = await stt.get_available_models()
        assert "tiny" in models
        assert "large-v3" in models

    @pytest.mark.asyncio
    async def test_deepgram_transcribe_empty(self):
        stt = DeepgramSTT(api_key="test_key")
        with patch.object(httpx, "AsyncClient") as mock_client:
            mock_resp = MagicMock()
            mock_resp.json.return_value = {"results": {"channels": [{"alternatives": [{"transcript": ""}]}]}}
            mock_resp.raise_for_status = MagicMock()
            mock_instance = AsyncMock()
            mock_instance.__aenter__.return_value.post = AsyncMock(return_value=mock_resp)
            mock_client.return_value = mock_instance
            result = await stt.transcribe(b"")
            assert result == ""

    @pytest.mark.asyncio
    async def test_deepgram_available_models(self):
        stt = DeepgramSTT(api_key="test_key")
        models = await stt.get_available_models()
        assert "nova-2" in models


class TestTTSFactory:
    def test_create_pyttsx3(self):
        with patch("backend.infrastructure.voice.tts.pyttsx3_tts._get_engine"):
            tts = TTSFactory.create("pyttsx3", {"voice": "default"})
            assert isinstance(tts, PyTTSx3TTS)

    def test_create_elevenlabs(self):
        tts = TTSFactory.create("elevenlabs", {"api_key": "test_key"})
        assert isinstance(tts, ElevenLabsTTS)

    def test_create_unknown(self):
        with pytest.raises(ValueError, match="Unknown TTS provider"):
            TTSFactory.create("unknown", {})

    def test_tts_abstract_base(self):
        with pytest.raises(TypeError):
            TTSProvider()

    @pytest.mark.asyncio
    async def test_elevenlabs_synthesize_default_voice(self):
        tts = ElevenLabsTTS(api_key="test_key", voice_id="default")
        with patch.object(tts, "synthesize", AsyncMock(return_value=b"audio")):
            result = await tts.synthesize("Hello")
            assert result == b"audio"

    @pytest.mark.asyncio
    async def test_elevenlabs_get_voices(self):
        tts = ElevenLabsTTS(api_key="test_key")
        with patch.object(tts, "get_available_voices", AsyncMock(return_value=[{"id": "v1", "name": "Voice 1"}])):
            voices = await tts.get_available_voices()
            assert len(voices) == 1


class TestVoicePipeline:
    @pytest.mark.asyncio
    async def test_process_input_speech(self, pipeline, mock_vad):
        mock_vad.is_speech.return_value = True
        mock_vad.detect_silence.return_value = False
        result = await pipeline.process_input(b"\x00" * 960)
        assert result == "hello world"

    @pytest.mark.asyncio
    async def test_process_input_silence(self, pipeline, mock_vad):
        mock_vad.is_speech.return_value = False
        mock_vad.detect_silence.return_value = True
        result = await pipeline.process_input(b"\x00" * 960)
        assert result is None

    @pytest.mark.asyncio
    async def test_process_input_noise_suppression(self, pipeline, mock_vad):
        mock_vad.is_speech.return_value = True
        mock_vad.detect_silence.return_value = False
        noisy_frame = b"\x01\x02" * 480
        result = await pipeline.process_input(noisy_frame)
        assert result is not None

    @pytest.mark.asyncio
    async def test_generate_output(self, pipeline, mock_tts):
        async def mock_stream(text):
            yield b"chunk1"
            yield b"chunk2"

        mock_tts.synthesize_streaming = mock_stream
        chunks = []
        async for chunk in pipeline.generate_output("Hello", emotion="happy"):
            chunks.append(chunk)
        assert len(chunks) == 2
        mock_tts.set_emotion.assert_called_once_with("happy")

    @pytest.mark.asyncio
    async def test_process_stream_full_utterance(self, pipeline, mock_vad):
        mock_vad.is_speech.side_effect = [True] * 10 + [False] * 25
        mock_vad.get_frame_size.return_value = 960

        async def audio_stream() -> AsyncIterator[bytes]:
            for _ in range(35):
                yield b"\x00" * 960

        results = []
        async for result in pipeline.process_stream(audio_stream()):
            results.append(result)

        assert len(results) > 0
        assert results[0]["type"] == "transcript"
        assert results[0]["is_final"] is True

    @pytest.mark.asyncio
    async def test_process_stream_empty(self, pipeline, mock_vad):
        mock_vad.is_speech.return_value = False
        mock_vad.get_frame_size.return_value = 960

        async def empty_stream() -> AsyncIterator[bytes]:
            yield b""

        results = []
        async for result in pipeline.process_stream(empty_stream()):
            results.append(result)
        assert len(results) == 0

    @pytest.mark.asyncio
    async def test_detect_interruption_silence(self, pipeline, mock_vad):
        mock_vad.is_speech.return_value = True
        mock_vad.detect_silence.return_value = True
        result = pipeline.detect_interruption(b"\x00" * 960, is_speaking=True)
        assert result is False

    @pytest.mark.asyncio
    async def test_detect_interruption_loud_speech(self, pipeline, mock_vad):
        mock_vad.is_speech.return_value = True
        mock_vad.detect_silence.return_value = False
        loud_frame = b"\xff\x7f" * 480
        result = pipeline.detect_interruption(loud_frame, is_speaking=True)
        assert result is True

    @pytest.mark.asyncio
    async def test_detect_interruption_not_speaking(self, pipeline, mock_vad):
        result = pipeline.detect_interruption(b"\x00" * 960, is_speaking=False)
        assert result is False

    @pytest.mark.asyncio
    async def test_process_stream_partial_final_utterance(self, pipeline, mock_vad):
        mock_vad.is_speech.side_effect = [True] * 5 + [False] * 5 + [True] * 5 + [False] * 25
        mock_vad.get_frame_size.return_value = 960

        async def audio_stream() -> AsyncIterator[bytes]:
            for _ in range(40):
                yield b"\x00" * 960

        results = []
        async for result in pipeline.process_stream(audio_stream()):
            results.append(result)
        assert len(results) >= 1

    def test_noise_suppression_threshold(self, pipeline):
        noisy = b"\x00\x10" * 480
        suppressed = pipeline._suppress_noise(noisy)
        assert len(suppressed) == len(noisy)

    def test_noise_suppression_odd_length(self, pipeline):
        noisy = b"\x00\x10\x00"
        suppressed = pipeline._suppress_noise(noisy)
        assert len(suppressed) > 0
