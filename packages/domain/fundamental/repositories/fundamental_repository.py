"""FundamentalRepository — Protocol the infrastructure layer implements.

Per financial-data-protocol Rule 1 (Point-in-Time Integrity): repository
methods are explicit about as-of semantics. There is intentionally NO
`get_all()` method — backtest paths must call `get_as_of(ticker, as_of_date)`
so look-ahead bias is structurally prevented (I-S2). The companion
`get_latest(ticker)` is reserved for live paths only.

Implementations land at:
- packages/infrastructure/fundamental/sqlite_fundamental_repository.py (S34)
- packages/infrastructure/fundamental/postgres_fundamental_repository.py (Phase 3+)
"""

from __future__ import annotations

from datetime import date
from typing import Protocol

from packages.contracts import Ticker
from packages.domain.fundamental.models import FinancialStatement
from packages.domain.fundamental.value_objects import StatementType

__all__ = ["FundamentalRepository"]


class FundamentalRepository(Protocol):
    """Read interface for FinancialStatement persistence. No write methods —
    ingestion adapters write directly per architecture.md § Repository Pattern.
    """

    def get_as_of(
        self,
        ticker: Ticker,
        as_of_date: date,
        statement_type: StatementType | None = None,
    ) -> list[FinancialStatement]:
        """Statements with period_end ≤ as_of_date AND filing_date ≤ as_of_date.

        Used by backtest paths. Enforces point-in-time per Rule 1 + I-S2.
        Result sorted by period_end ascending. When `statement_type` is None,
        all three classes (IS/BS/CF) are returned interleaved.
        """
        ...

    def get_latest(self, ticker: Ticker) -> FinancialStatement | None:
        """The most recent FinancialStatement for `ticker` regardless of type,
        or None if no statements exist. Live paths only — not backtest-safe.
        """
        ...
