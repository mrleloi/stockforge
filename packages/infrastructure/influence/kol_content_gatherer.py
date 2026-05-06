"""KOLContentGatherer — D-026 BP-S43b-3 gatherer-wired deterministic compute.

Prepares the full extraction context before the LLM is invoked, ensuring that
all numeric or structured values (timestamps, channel metadata, configuration
thresholds) originate from deterministic Python code — never from LLM output.

This is the concrete implementation of the "Gatherer-wired deterministic compute"
pattern cited verbatim in `llm_recommendation_extractor.py` per D-026 (BP-S43b-3):

    "Numbers come from code (Charter Principle 9 / I-S1) — wire deterministic
    services (RatioService, TaService, etc.) through the gatherer that prepares
    LLM context, not through the LLM agent itself."

Q-S47-1 Whisper model: stub-only in Phase 3. Live YouTube transcription via
Whisper (local whisper-cpp or OpenAI Whisper API) is deferred to the actual
ingestion pipeline in Phase 4. The gatherer ASSUMES the caller has already
resolved a transcript string (from Whisper, Facebook text, or Telegram text).
The `WhisperTranscriber` stub is documented here for Phase 4 wiring.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.3 UC-1 + § B.4.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § d).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import UTC, datetime

from packages.domain.influence.models.channel import Channel
from packages.domain.influence.models.channel_content import ChannelContent

__all__ = ["ExtractionContext", "KOLContentGatherer"]

# Extraction configuration constants — come from code, not LLM (I-S1).
_DEFAULT_EXTRACTOR_VERSION = "1.0.0"
_CONFIDENCE_THRESHOLD = 0.7        # BR-6; gatherer stamps this in config for extractor
_MAX_TRANSCRIPT_CHARS = 12_000     # Safety cap before truncation; avoids runaway tokens
_TRANSCRIPT_EXCERPT_MAX_CHARS = 500  # BR-10 / spec § B.6


@dataclass(frozen=True, slots=True)
class ExtractionContext:
    """Immutable bundle passed to LLMRecommendationExtractor.

    All numeric/structured fields originate from deterministic code.
    The extractor uses this context to hydrate Recommendation aggregates
    and configure the LLM substrate call.

    Fields:
        transcript              Cleaned, UTF-8 plain-text transcript.
        source_metadata         Original ChannelContent providing provenance.
        channel                 Owning Channel entity (kol_id, platform).
        extraction_config       Strategy config (model, version, threshold).
        gathered_at             Wall-clock of this context assembly.
    """

    transcript: str
    source_metadata: ChannelContent
    channel: Channel
    extraction_config: dict[str, object]
    gathered_at: datetime = field(default_factory=lambda: datetime.now(UTC))


@dataclass
class KOLContentGatherer:
    """Prepares ExtractionContext for the LLM extractor (BP-S43b-3).

    Responsibilities:
    1. Normalise transcript text (strip nulls, enforce char limit).
    2. Assemble extraction_config with all deterministic parameters so
       the LLM extractor does NOT hard-code thresholds internally.
    3. Attach provenance fields from ChannelContent (source_url, published_at).

    This class does NOT call the LLM. It only assembles the context bundle.

    Q-S47-1 deferral: `transcribe_media_url()` is a Phase 4 stub. In Phase 3
    the caller is responsible for providing a pre-transcribed text in
    ChannelContent.raw_text. Phase 4 wiring:
        gatherer.transcribe_media_url(content.media_urls[0])
    will route to WhisperLocalTranscriber (cost) or WhisperApiTranscriber
    (hard-audio fallback) per spec § B.4 Transcribers.

    Args:
        extractor_version:  Code version tag embedded in every extracted
                            Recommendation for audit (BR-10).
        confidence_threshold: BR-6 threshold; defaults to 0.7.
        max_transcript_chars: Safety truncation cap before token bloat.
    """

    extractor_version: str = _DEFAULT_EXTRACTOR_VERSION
    confidence_threshold: float = _CONFIDENCE_THRESHOLD
    max_transcript_chars: int = _MAX_TRANSCRIPT_CHARS

    def gather(
        self,
        channel: Channel,
        content: ChannelContent,
        transcript: str | None = None,
    ) -> ExtractionContext:
        """Build ExtractionContext from channel + content + optional transcript override.

        If `transcript` is None, falls back to content.raw_text.
        Truncates to max_transcript_chars to prevent token overflow.

        All numeric values in extraction_config come from this method —
        the LLM extractor MUST use them rather than re-deriving from its own
        internal state (BP-S43b-3 gathering pattern).
        """
        raw = transcript if transcript is not None else content.raw_text
        cleaned = self._clean_transcript(raw)

        extraction_config: dict[str, object] = {
            "extractor_version": self.extractor_version,
            "confidence_threshold": self.confidence_threshold,
            "transcript_excerpt_max_chars": _TRANSCRIPT_EXCERPT_MAX_CHARS,
            "source_url": content.source_url,
            "channel_id": str(content.channel_id),
            "published_at_iso": content.published_at.isoformat(),
            "platform": channel.platform.value if hasattr(channel.platform, "value") else str(channel.platform),
            "kol_id": str(channel.kol_id) if channel.kol_id else None,
        }

        return ExtractionContext(
            transcript=cleaned,
            source_metadata=content,
            channel=channel,
            extraction_config=extraction_config,
        )

    def _clean_transcript(self, raw: str) -> str:
        """Normalise and truncate transcript text.

        - Strip null bytes (common in whisper/yt-dlp output).
        - Normalise Windows line endings.
        - Truncate at max_transcript_chars with a warning marker.
        """
        cleaned = raw.replace("\x00", "").replace("\r\n", "\n").replace("\r", "\n")
        if len(cleaned) > self.max_transcript_chars:
            # Truncation marker so the LLM knows it received partial content.
            cleaned = (
                cleaned[: self.max_transcript_chars]
                + "\n\n[TRANSCRIPT TRUNCATED — partial input]"
            )
        return cleaned

    def transcribe_media_url(self, media_url: str) -> str:
        """STUB — Phase 4 placeholder for Whisper transcription.

        Q-S47-1 deferral: Live YouTube/podcast transcription via Whisper
        (local whisper-cpp or OpenAI Whisper API) is deferred to Phase 4
        ingestion pipeline. Phase 3 callers must pre-transcribe content
        and pass the result via ChannelContent.raw_text.

        Phase 4 implementation will:
            1. Route local audio (<25MB) to WhisperLocalTranscriber
            2. Fallback hard audio to WhisperApiTranscriber
            3. Return plain UTF-8 transcript string

        Args:
            media_url: URL of the audio/video file to transcribe.

        Returns:
            Empty string (stub); will return transcript in Phase 4.
        """
        _ = media_url  # Phase 4 will use this
        return ""
