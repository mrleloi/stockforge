"""BarRepository — Protocol the infrastructure layer implements.

Per financial-data-protocol Rule 1 (Point-in-Time Integrity): repository
methods are explicit about as-of semantics. There is intentionally NO
`get_all()` method — backtest paths must call `get_range_adjusted` with
explicit start/end so look-ahead bias is structurally prevented (I-S2).

Implementations land at:
- packages/infrastructure/market_data/sqlite_bar_repository.py (S28 deliverable)
- packages/infrastructure/market_data/postgres_bar_repository.py (Phase 2+)
"""

from __future__ import annotations

from datetime import date
from typing import Protocol

from packages.contracts import Ticker
from packages.domain.market_data.models import Bar

__all__ = ["BarRepository"]


class BarRepository(Protocol):
    """Read interface for Bar persistence. No write methods on this Protocol —
    ingestion adapters write directly per architecture.md § Repository Pattern.
    """

    def get_as_of(self, ticker: Ticker, as_of_date: date) -> list[Bar]:
        """Bars whose period_end ≤ as_of_date AND filing_date ≤ as_of_date.

        Used by backtest paths. Enforces point-in-time per Rule 1 + I-S2.
        Result is sorted by period_end ascending.
        """
        ...

    def get_latest(self, ticker: Ticker) -> Bar | None:
        """The most recent Bar for `ticker`, or None if no bars exist.

        Used by live paths. Returns a Bar regardless of filing_date filter —
        not safe for backtest replay.
        """
        ...

    def get_range_adjusted(
        self, ticker: Ticker, start: date, end: date
    ) -> list[Bar]:
        """Bars with period_end in [start, end], adjustment_type == BOTH.

        Used by chart + return calculations. Per Rule 3, mixing adjustment
        types in same query is a bug class — this method narrows to BOTH only.
        Result sorted by period_end ascending.
        """
        ...
