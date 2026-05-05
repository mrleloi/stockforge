"""NewsArticle — atomic ingested-news record per spec-T1-001 § B.2.

Aggregate root for a single article scraped from CafeF / Vietstock / NDH /
VietnamBiz / Đầu Tư Chứng Khoán. The full body is intentionally NOT held
in-memory on the entity — production deployments persist body to R2 and only
keep a `body_excerpt` (≤ 8 KB) on the entity. Phase 2 thin slice keeps the
excerpt local to the DB for substrate simplicity (deferred to Phase 3 per
spec-T1-001 § B.6 + master-plan 005 § S36).

Invariants enforced in __post_init__:
- Rule 8 (anti-look-ahead): published_at ≤ ingested_at (we cannot ingest a
  not-yet-published article).
- I-1 / Rule 6: source_url non-empty (every record traces to a URL).
- Rule 6 mirror: title non-empty, source non-empty.

Source: specs/tier1-strategic/001-four-tier-signal-architecture.md § B.2;
agent-workspace/constitution/financial-data-protocol.md Rule 6 + Rule 8.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime

from packages.contracts import Ticker

__all__ = ["NewsArticle", "NewsArticleInvariantError"]


class NewsArticleInvariantError(ValueError):
    """Raised when a NewsArticle violates Rule 6 / Rule 8 / I-1 invariants."""


@dataclass(frozen=True, slots=True)
class NewsArticle:
    """Immutable ingested-news record.

    `mentioned_tickers` is the *coarse* keyword scan performed at ingest time
    (CLI grep over title + excerpt against the UL universe). Fine-grained
    extraction is the LLM's job and lands on `ExtractedClaim`. Keeping the
    coarse scan here lets the CLI shard ingestion per ticker without paying
    LLM cost for irrelevant articles.
    """

    article_id: str
    source: str
    source_url: str
    title: str
    body_excerpt: str
    published_at: datetime
    ingested_at: datetime
    mentioned_tickers: tuple[Ticker, ...] = field(default_factory=tuple)
    language: str = "vi"

    def __post_init__(self) -> None:
        if not self.article_id.strip():
            raise NewsArticleInvariantError("article_id is required")
        if not self.source.strip():
            raise NewsArticleInvariantError("source is required (Rule 6)")
        if not self.source_url.strip():
            raise NewsArticleInvariantError("source_url is required (I-1 / Rule 6)")
        if not self.title.strip():
            raise NewsArticleInvariantError("title is required (Rule 6)")
        if self.published_at > self.ingested_at:
            raise NewsArticleInvariantError(
                f"published_at {self.published_at.isoformat()} > ingested_at "
                f"{self.ingested_at.isoformat()} (Rule 8 — cannot ingest the future)"
            )

    def mentions(self, ticker: Ticker) -> bool:
        """True if the coarse scan tagged `ticker` for this article."""
        return ticker in self.mentioned_tickers
