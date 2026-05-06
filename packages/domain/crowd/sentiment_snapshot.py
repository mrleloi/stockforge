"""SentimentSnapshot — aggregate for ticker crowd sentiment over a time window.

Invariants (D-032 § c):
- sentiment_distribution must be non-empty
- coordinated_posting_score must be in [0.0, 1.0]
- posting_velocity must be >= 0.0
- captured_at must not be in the future (validated at construction)

Behaviors per spec § B.1:
- dominant_sentiment(): returns most-voted Sentiment enum value
- bullish_ratio(): fraction of bullish+strongly_bullish over total

I-S1: NO LLM math. All numeric fields computed deterministically in infrastructure
layer (CrowdContentGatherer + CaptureSentimentSnapshotUseCase). LLM ONLY classifies
categorical Sentiment enum per BR-4.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1 + B.3 UC-1.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § c).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime

from packages.domain.crowd.value_objects.sentiment import Sentiment
from packages.domain.crowd.value_objects.snapshot_id import SnapshotId
from packages.domain.crowd.value_objects.window import Window

__all__ = ["SentimentSnapshot"]


@dataclass(frozen=True)
class SentimentSnapshot:
    """Aggregate sentiment for a ticker over a time window.

    All fields are immutable (frozen=True). Mutations require creating a new instance.
    Provenance: captured_at + sources per I-S2.
    """

    snapshot_id: SnapshotId
    ticker: str
    captured_at: datetime
    window: Window
    mention_count: int
    sentiment_distribution: dict[Sentiment, int]   # counts per category
    posting_velocity: float                         # posts/hour
    unique_posters: int
    coordinated_posting_score: float               # 0.0-1.0 from CoordinationDetector
    sources: dict[str, int]                        # source_platform -> mention_count
    top_terms: tuple[str, ...]                     # most common phrases
    source_posts_sample: tuple[str, ...]           # max 20 post_ids for debugging (BR-3)

    def __post_init__(self) -> None:
        if not self.sentiment_distribution:
            raise ValueError("SentimentSnapshot.sentiment_distribution must be non-empty")
        if not (0.0 <= self.coordinated_posting_score <= 1.0):
            raise ValueError(
                f"coordinated_posting_score must be in [0, 1], "
                f"got {self.coordinated_posting_score}"
            )
        if self.posting_velocity < 0.0:
            raise ValueError(
                f"posting_velocity must be >= 0, got {self.posting_velocity}"
            )
        if self.mention_count < 0:
            raise ValueError(f"mention_count must be >= 0, got {self.mention_count}")
        # captured_at must not be meaningfully in the future (60s tolerance for clock skew)
        captured_utc = (
            self.captured_at
            if self.captured_at.tzinfo is not None
            else self.captured_at.replace(tzinfo=UTC)
        )
        now_utc = datetime.now(UTC)
        if (captured_utc - now_utc).total_seconds() > 60:
            raise ValueError(
                f"captured_at must not be in the future, got {self.captured_at}"
            )

    def dominant_sentiment(self) -> Sentiment:
        """Return the Sentiment with the highest mention count.

        Deterministic: max by count; tie-broken by dict insertion order.
        I-S1: this computation runs in Python, not LLM.
        """
        return max(self.sentiment_distribution.items(), key=lambda x: x[1])[0]

    def bullish_ratio(self) -> float:
        """Fraction of (BULLISH + STRONGLY_BULLISH) posts over total posts.

        Returns 0.0 if total is zero. Used by BR-6 counter-narrative trigger (> 0.8).
        I-S1: deterministic Python computation — no LLM involvement.
        """
        total = sum(self.sentiment_distribution.values())
        if total == 0:
            return 0.0
        bullish = (
            self.sentiment_distribution.get(Sentiment.BULLISH, 0)
            + self.sentiment_distribution.get(Sentiment.STRONGLY_BULLISH, 0)
        )
        return bullish / total
