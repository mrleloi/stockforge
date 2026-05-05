"""NewsRepository — Protocol the infrastructure layer implements.

Per financial-data-protocol Rule 8 (Anti-Look-Ahead in News): backtest paths
MUST go through `get_known_as_of` — the substrate enforces both
`published_at <= as_of_date` AND `ingested_at <= as_of_date`. There is
intentionally NO `get_all()` so look-ahead bias is structurally prevented.
"""

from __future__ import annotations

from datetime import date, datetime
from typing import Protocol

from packages.contracts import Ticker
from packages.domain.news.models import NewsArticle

__all__ = ["NewsRepository"]


class NewsRepository(Protocol):
    """Read + write interface for NewsArticle persistence.

    Live ingestion paths use `save_many`; backtest paths read via
    `get_known_as_of`. Live UI / read-throughs use `get_recent` (NOT
    backtest-safe).
    """

    def save_many(self, articles: list[NewsArticle]) -> int:
        """Persist articles; return count actually written. Idempotent on
        article_id (re-running the scraper converges).
        """
        ...

    def get_known_as_of(
        self,
        ticker: Ticker,
        as_of_date: date,
        acting_lag_minutes: int = 0,
    ) -> list[NewsArticle]:
        """Articles a backtester at `as_of_date` could legitimately have read.

        Per Rule 8: WHERE published_at + acting_lag <= action_date AND
        ingested_at <= as_of_date. Acting lag defaults to 0 minutes; raise it
        to e.g. 60 to model "we don't trade within an hour of news landing".
        """
        ...

    def get_recent(self, ticker: Ticker, since: datetime) -> list[NewsArticle]:
        """Live path: articles with ingested_at >= since. Not backtest-safe.

        Sort: published_at DESC.
        """
        ...

    def count(self) -> int:
        ...
