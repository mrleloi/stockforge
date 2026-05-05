"""FinancialStatementFiled — BC-2 emits when a new statement lands on disk.

Cross-BC contract event. BC-2 (Fundamental) owns emission; downstream
consumers (BC-8 Analysis for thesis re-validation, future scheduler for
peer-distribution refresh) read from the event without taking a domain
dependency on Fundamental.

Phase 2 thin slice (S34 Track C): in-process synchronous emission per
architecture.md § Event Flow Phase 2 (no broker yet). Phase 3+ adds Redis
Streams / Dramatiq for async dispatch.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime

from packages.contracts.types import SourceProvider, Ticker

__all__ = ["FinancialStatementFiled"]


@dataclass(frozen=True, slots=True)
class FinancialStatementFiled:
    """Past-tense fact: a FinancialStatement was filed and persisted.

    Phase 2 invariants (validated in __post_init__):
    - filing_date >= period_end (filing cannot precede the reported period;
      Rule 1 mirror of FinancialStatement entity invariant)
    - emitted_at is wall-clock at emission time (audit-only; not used in
      backtest filtering)
    - statement_type is one of "is" / "bs" / "cf" (kept as raw str for
      cross-BC tolerance — BC-8 doesn't import the StatementType enum)
    """

    ticker: Ticker
    statement_type: str
    period_end: date
    filing_date: date
    source_provider: SourceProvider
    emitted_at: datetime

    def __post_init__(self) -> None:
        if not isinstance(self.ticker, Ticker):
            raise TypeError(f"ticker must be Ticker, got {type(self.ticker).__name__}")
        if self.statement_type not in {"is", "bs", "cf"}:
            raise ValueError(
                f"statement_type must be 'is' / 'bs' / 'cf', got {self.statement_type!r}"
            )
        if self.filing_date < self.period_end:
            raise ValueError(
                f"filing_date {self.filing_date} < period_end {self.period_end} (Rule 1)"
            )
        if not isinstance(self.emitted_at, datetime):
            raise TypeError(
                f"emitted_at must be datetime.datetime, got {type(self.emitted_at).__name__}"
            )
