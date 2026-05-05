"""FinancialStatement — atomic Vietnamese financial-report record.

Phase 2 thin slice (S34 Track C): single statement (one of IS/BS/CF) per record;
restated_at tracking deferred to Phase 3 per spec-T1-001 § B.1 "Restated
financials happen (track via restated_at field)" — flagged informational here.

Invariants enforced in __post_init__:
- Rule 1 (point-in-time integrity): filing_date ≥ period_end (filing happens
  at OR after period close — same day allowed for monthly/preliminary filings).
- Rule 1 (anti-look-ahead): period_end ≤ today (no future periods).
- Rule 1 (ingestion-after-filing): ingested_at.date() ≥ filing_date.
- I-S5 + Rule 4: source_provider non-None (StrEnum guarantees).
- Rule 6 + I-S1: line_items dict non-empty AND every value is Money (so ratio
  formulas downstream cannot accidentally divide a float-pennies number).
- I-S6 + Rule 5: every Money value within line_items shares the same currency
  (FinancialStatement is single-currency; cross-currency comparisons require
  explicit FX conversion at the service layer).

Source: agent-workspace/constitution/architecture.md § BC-2 Fundamental;
financial-data-protocol.md Rule 1 + Rule 4 + Rule 5 + Rule 6;
specs/tier1-strategic/001-four-tier-signal-architecture.md § B.1.
"""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass, field
from datetime import UTC, date, datetime

from packages.contracts import Currency, Money, SourceProvider, Ticker
from packages.domain.fundamental.value_objects import LineItemKey, StatementType

__all__ = ["FinancialStatement", "FinancialStatementInvariantError"]


class FinancialStatementInvariantError(ValueError):
    """Raised when a FinancialStatement is constructed with values violating
    Rule 1 / Rule 4 / Rule 5 / Rule 6 / I-S1.
    """


@dataclass(frozen=True, slots=True)
class FinancialStatement:
    """Immutable Vietnamese financial-statement record. Rich entity per
    architecture.md § Domain Model Rules.

    `line_items` is a frozen-by-convention dict (typed as Mapping for read-only
    intent; Python doesn't ship a frozendict). Mutating the dict post-construct
    breaks the dataclass equality contract — callers MUST treat it as immutable.
    """

    ticker: Ticker
    statement_type: StatementType
    period_end: date
    filing_date: date
    ingested_at: datetime
    line_items: Mapping[str, Money]
    source_provider: SourceProvider
    sector: str | None = None
    restated_at: datetime | None = None
    fiscal_period_label: str = field(default="")

    def __post_init__(self) -> None:
        today = datetime.now(UTC).date()
        if self.period_end > today:
            raise FinancialStatementInvariantError(
                f"period_end {self.period_end} > today {today} (look-ahead bias; Rule 1 / I-S2)"
            )
        if self.filing_date < self.period_end:
            raise FinancialStatementInvariantError(
                f"filing_date {self.filing_date} < period_end {self.period_end} "
                f"(filing cannot precede the period it reports; Rule 1)"
            )
        if self.ingested_at.date() < self.filing_date:
            raise FinancialStatementInvariantError(
                f"ingested_at {self.ingested_at.date()} < filing_date {self.filing_date} "
                f"(ingestion cannot precede filing; Rule 1)"
            )
        if not self.line_items:
            raise FinancialStatementInvariantError(
                f"{self.statement_type.value} for {self.ticker} has empty line_items (Rule 6 / I-S1)"
            )
        currencies = {m.currency for m in self.line_items.values()}
        if len(currencies) > 1:
            raise FinancialStatementInvariantError(
                f"line_items currency mismatch {sorted(c.value for c in currencies)} "
                f"(I-S6 + Rule 5; FinancialStatement is single-currency)"
            )

    @property
    def currency(self) -> Currency:
        first = next(iter(self.line_items.values()))
        return first.currency

    def get_line_item(self, key: str | LineItemKey) -> Money | None:
        """Return the Money value for `key` if present, else None.

        Accepts both raw str and LineItemKey enum so call sites can read either
        the canonical key (preferred for ratio_service) or the raw string (for
        adapter-time lookup before normalization is complete).
        """
        lookup_key = key.value if isinstance(key, LineItemKey) else key
        return self.line_items.get(lookup_key)

    def has_line_items(self, *keys: str | LineItemKey) -> bool:
        """True if every named key is present in line_items (and value Money)."""
        return all(self.get_line_item(key) is not None for key in keys)
