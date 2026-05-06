"""SentimentSnapshotCaptured — cross-BC event for crowd sentiment capture (BC-7).

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.2.
ADR: D-032 § (c) domain events.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

__all__ = ["SentimentSnapshotCaptured"]


@dataclass(frozen=True)
class SentimentSnapshotCaptured:
    """Event emitted after successful SentimentSnapshot capture.

    Carries lightweight summary; consumers fetch full snapshot from repo by ID.
    """

    ticker: str
    window: str             # Window.value e.g. "1H"
    captured_at: datetime
    dominant_sentiment: str  # Sentiment.value e.g. "bullish"
    mention_count: int
    snapshot_id: str
