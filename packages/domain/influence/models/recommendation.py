"""Recommendation — BC-6 Recommendation aggregate root.

Represents a single extracted investment recommendation from a KOL transcript.
Enforces provenance (BR-10), confidence threshold (BR-6), conditional-flag
separation (BR-7), and transcript excerpt length limit (spec § B.6 ≤500 chars).

Invariants enforced in `__post_init__`:
- BR-10: source_url + transcript_excerpt + extractor_model + extractor_version
  + extracted_at ALL must be present; insert fails if any missing.
- BR-6: extraction_confidence < 0.7 is allowed ONLY when requires_manual_review=True;
  if confidence < 0.7 AND requires_manual_review=False → InvariantViolation.
- BR-7: conditional recommendations stored verbatim in `conditions` list; caller
  must evaluate conditions independently; outcome window is INVALID until condition met.
- transcript_excerpt ≤500 chars per spec § B.6 / B.10.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § A.3 BR-6/7/10.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § c).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import UTC, datetime

from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.intent import Intent
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.recommendation_id import RecommendationId
from packages.domain.influence.value_objects.timeframe import Timeframe

__all__ = ["InvariantViolation", "Recommendation"]

# BR-6 threshold — extraction_confidence must meet this to auto-accept.
_EXTRACTION_CONFIDENCE_THRESHOLD = 0.7

# BR-10 transcript excerpt maximum length in characters (spec § B.6).
_TRANSCRIPT_EXCERPT_MAX_CHARS = 500


class InvariantViolation(ValueError):
    """Raised when a Recommendation invariant is violated at construction time."""


@dataclass
class Recommendation:
    """BC-6 Recommendation aggregate root.

    Extracted from a KOL transcript by the LLM extractor (Track H).

    Fields:
        recommendation_id       Stable opaque ID (uuid4 or hash).
        kol_id                  Owning KOL.
        channel_id              Source channel.
        ticker                  VN stock symbol (e.g. HPG, VIC, FPT).
        intent                  Directional intent — see Intent enum.
        timeframe               Stated investment horizon — see Timeframe enum.
        source_url              Canonical public URL (BR-10 provenance).
        timestamp_in_source     e.g. "12:34-13:02" for video; "" for text posts.
        transcript_excerpt      Exact quote ≤500 chars (BR-10 + spec § B.6).
        extraction_confidence   0-1 LLM confidence in extraction accuracy (NOT
                                confidence in the recommendation itself).
        extractor_model         LLM model ID used (e.g. "claude-sonnet-4-6").
        extractor_version       Extractor code version tag (e.g. "1.0.0").
        extracted_at            Wall-clock datetime of extraction (I-S2).
        published_at            Content publication timestamp from platform.
        conditions              Empty = unconditional; non-empty = BR-7 conditional.
        requires_manual_review  True if extraction_confidence < 0.7 (BR-6).
        flip_from_recommendation_id  Non-None if this reverses a prior call.

    NOTE (I-S35): KOL recommendations are tracked as research subjects. This
    aggregate represents a data point, NOT financial advice.
    """

    recommendation_id: RecommendationId
    kol_id: KolId
    channel_id: ChannelId
    ticker: str
    intent: Intent
    timeframe: Timeframe
    source_url: str
    transcript_excerpt: str
    extraction_confidence: float
    extractor_model: str
    extractor_version: str
    extracted_at: datetime
    published_at: datetime
    timestamp_in_source: str = ""
    conditions: list[str] = field(default_factory=list)
    requires_manual_review: bool = False
    flip_from_recommendation_id: RecommendationId | None = None

    def __post_init__(self) -> None:
        # --- BR-10: provenance fields ---
        if not self.source_url or not self.source_url.strip():
            raise InvariantViolation(
                "BR-10: source_url is required for every Recommendation"
            )
        if not self.transcript_excerpt or not self.transcript_excerpt.strip():
            raise InvariantViolation(
                "BR-10: transcript_excerpt is required for every Recommendation"
            )
        if not self.extractor_model or not self.extractor_model.strip():
            raise InvariantViolation(
                "BR-10: extractor_model is required for every Recommendation"
            )
        if not self.extractor_version or not self.extractor_version.strip():
            raise InvariantViolation(
                "BR-10: extractor_version is required for every Recommendation"
            )
        if self.extracted_at is None:
            raise InvariantViolation(
                "BR-10: extracted_at is required for every Recommendation"
            )

        # --- transcript_excerpt length cap (spec § B.6 / BR-10) ---
        if len(self.transcript_excerpt) > _TRANSCRIPT_EXCERPT_MAX_CHARS:
            raise InvariantViolation(
                f"transcript_excerpt exceeds {_TRANSCRIPT_EXCERPT_MAX_CHARS} chars "
                f"(got {len(self.transcript_excerpt)}); truncate before construction"
            )

        # --- BR-6: confidence threshold ---
        if (
            self.extraction_confidence < _EXTRACTION_CONFIDENCE_THRESHOLD
            and not self.requires_manual_review
        ):
            raise InvariantViolation(
                f"BR-6: extraction_confidence {self.extraction_confidence:.3f} < "
                f"{_EXTRACTION_CONFIDENCE_THRESHOLD}; set requires_manual_review=True "
                "to route to the manual review queue instead"
            )

        # --- confidence range ---
        if not (0.0 <= self.extraction_confidence <= 1.0):
            raise InvariantViolation(
                f"extraction_confidence must be in [0, 1]; got {self.extraction_confidence}"
            )

        # --- ticker non-empty ---
        if not self.ticker or not self.ticker.strip():
            raise InvariantViolation("ticker must be a non-empty VN stock symbol")

    # --- behaviour ---

    def is_conditional(self) -> bool:
        """Return True if recommendation has entry conditions (BR-7).

        Conditional recommendations should only be evaluated when their
        conditions have been met. If conditions were never met, outcome
        should be marked INVALID (not MISS).
        """
        return bool(self.conditions)

    def is_strong_directional(self) -> bool:
        """Return True if intent is STRONG_BUY or STRONG_AVOID."""
        return self.intent in (Intent.STRONG_BUY, Intent.STRONG_AVOID)

    def is_auto_accepted(self) -> bool:
        """Return True when extraction confidence meets BR-6 threshold.

        Auto-accepted recommendations go directly to the recommendation
        repository. Low-confidence ones require manual review.
        """
        return self.extraction_confidence >= _EXTRACTION_CONFIDENCE_THRESHOLD

    def provenance_dict(self) -> dict[str, str]:
        """Return BR-10 provenance fields as a serialisable dict.

        Useful for audit logs and event payloads.
        """
        return {
            "source_url": self.source_url,
            "timestamp_in_source": self.timestamp_in_source,
            "transcript_excerpt": self.transcript_excerpt,
            "extractor_model": self.extractor_model,
            "extractor_version": self.extractor_version,
            "extracted_at": self.extracted_at.isoformat(),
        }

    @property
    def age_seconds(self) -> float:
        """Seconds since extracted_at (for freshness checks)."""
        now = datetime.now(UTC)
        # Normalise tz-naive extracted_at
        extracted = self.extracted_at
        if extracted.tzinfo is None:
            extracted = extracted.replace(tzinfo=UTC)
        return max(0.0, (now - extracted).total_seconds())
