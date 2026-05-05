"""ClaimRepository — Protocol the infrastructure layer implements.

Per financial-data-protocol Rule 6 (LLM Output Provenance): claims persist
with mandatory provenance fields enforced at the entity level
(ExtractedClaim invariants). The repository simply mirrors that contract.
"""

from __future__ import annotations

from datetime import date
from typing import Protocol

from packages.contracts import Ticker
from packages.domain.news.models import ExtractedClaim

__all__ = ["ClaimRepository"]


class ClaimRepository(Protocol):
    """Read + write interface for ExtractedClaim persistence."""

    def save_many(self, claims: list[ExtractedClaim]) -> int:
        """Persist claims; idempotent on claim_id."""
        ...

    def get_for_ticker(
        self,
        ticker: Ticker,
        as_of_date: date | None = None,
    ) -> list[ExtractedClaim]:
        """Claims mentioning `ticker`. When `as_of_date` is given, the
        substrate joins to news_articles and filters by Rule 8 anti-look-ahead.
        """
        ...

    def count(self) -> int:
        ...
