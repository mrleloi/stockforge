"""ExtractedClaimPublished — BC-5 emits when a claim is persisted.

Cross-BC contract event. BC-8 Analysis subscribes to refresh thesis when
a watched ticker / sector receives a new claim. Carries provenance so
consumers can audit without re-reading the claim repository.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

from packages.contracts.types import Ticker

__all__ = ["ExtractedClaimPublished"]


_VALID_SENTIMENTS = frozenset(
    {
        "strongly_bullish",
        "bullish",
        "neutral",
        "bearish",
        "strongly_bearish",
    }
)


@dataclass(frozen=True, slots=True)
class ExtractedClaimPublished:
    """Past-tense fact: an LLM-extracted claim was persisted.

    Sentiment is the raw 5-class string (NOT the enum) per cross-BC
    tolerance principle — downstream consumers SHOULD validate against
    Sentiment enum but do not import it (avoids the BC-5 → BC-8 domain
    dependency).
    """

    claim_id: str
    article_id: str
    source_url: str
    sentiment: str
    mentioned_tickers: tuple[Ticker, ...]
    mentioned_sectors: tuple[str, ...]
    extractor_model: str
    extracted_at: datetime
    confidence_extracted: float
    emitted_at: datetime

    def __post_init__(self) -> None:
        if not self.claim_id.strip():
            raise ValueError("claim_id is required")
        if not self.article_id.strip():
            raise ValueError("article_id is required")
        if not self.source_url.strip():
            raise ValueError("source_url is required (Rule 6 / I-1)")
        if self.sentiment not in _VALID_SENTIMENTS:
            raise ValueError(
                f"sentiment {self.sentiment!r} not in {sorted(_VALID_SENTIMENTS)} (Rule 7)"
            )
        if not self.extractor_model.strip():
            raise ValueError("extractor_model is required (Rule 6)")
        if not 0.0 <= self.confidence_extracted <= 1.0:
            raise ValueError(
                f"confidence_extracted {self.confidence_extracted} outside [0, 1] (Rule 6)"
            )
        if not self.mentioned_tickers and not self.mentioned_sectors:
            raise ValueError(
                "claim event must mention at least one ticker or sector (Rule 6)"
            )
