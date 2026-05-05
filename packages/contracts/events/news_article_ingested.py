"""NewsArticleIngested — BC-5 emits when a news article lands on disk.

Cross-BC contract event. Downstream consumers (BC-8 Analysis for thesis
re-validation when a tracked ticker is mentioned, future scheduler for
cluster-detection refresh) read the event without taking a domain
dependency on News Stream.

Phase 2 thin slice (S36 Track D): in-process synchronous emission per
architecture.md § Event Flow Phase 2. Phase 3+ adds Redis Streams /
Dramatiq for async dispatch.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

from packages.contracts.types import Ticker

__all__ = ["NewsArticleIngested"]


@dataclass(frozen=True, slots=True)
class NewsArticleIngested:
    """Past-tense fact: a news article was scraped and persisted.

    `mentioned_tickers` carries the coarse-scan list (no LLM cost) so
    downstream consumers can short-circuit without re-reading the article.
    """

    article_id: str
    source: str
    source_url: str
    published_at: datetime
    ingested_at: datetime
    mentioned_tickers: tuple[Ticker, ...]
    emitted_at: datetime

    def __post_init__(self) -> None:
        if not self.article_id.strip():
            raise ValueError("article_id is required")
        if not self.source_url.strip():
            raise ValueError("source_url is required (Rule 6 / I-1)")
        if self.published_at > self.ingested_at:
            raise ValueError(
                f"published_at {self.published_at.isoformat()} > ingested_at "
                f"{self.ingested_at.isoformat()} (Rule 8 mirror)"
            )
        for t in self.mentioned_tickers:
            if not isinstance(t, Ticker):
                raise TypeError(
                    f"mentioned_tickers must be Ticker tuple, got {type(t).__name__}"
                )
