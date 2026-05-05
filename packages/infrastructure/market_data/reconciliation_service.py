"""ReconciliationService — pure-logic cross-source Bar reconciliation per Rule 4.

Takes Bar lists from two providers (VNSTOCK + TCBS in the S28 thin slice) and
emits a `ReconciledBar` view per (ticker, period_end) key. No LLM, no network,
no DB — pure deterministic comparison logic exercising financial-data-protocol
Rule 4 ("Source Attribution & Reconciliation").

Confidence rules (matches Rule 4 verbatim):
- Both sources present, divergence ≤ 1%: confidence = HIGH; reconciled close
  = arithmetic mean of the two close values.
- Both sources present, divergence > 1%: confidence = LOW; reconciled close
  = primary (vnstock) close; both source values surfaced for audit.
- Only one source has the day: confidence = SINGLE_SOURCE; reconciled close
  = whatever was available; the missing source is recorded.

Manual override path (Rule 4 final clause: "Manual override always wins, with
override_reason documented") is deferred to Phase 2 — Phase 1 thin-slice has
no human-in-the-loop reconciliation override per Q-S28-3.

Divergence formula: `abs(close_a - close_b) / max(close_a, close_b)`. Currency
must match across the two close values; cross-currency comparison raises
`CurrencyMismatchError` (re-raised from Money operators per Rule 5).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from decimal import Decimal
from enum import StrEnum

from packages.contracts import CurrencyMismatchError, Money, SourceProvider, Ticker
from packages.domain.market_data.models import Bar

__all__ = [
    "ReconciledBar",
    "ReconciliationConfidence",
    "ReconciliationService",
]


_DEFAULT_TOLERANCE = Decimal("0.01")  # 1% per Rule 4 (HOSE baseline)

# Per amendment-VN Rule 14 (PROPOSAL — not yet promoted to constitution):
# HOSE ±1% / HNX ±2% / UPCoM ±5%. Phase 2 / S33 scope = HOSE-only (VN30); the
# table is wired now so per-Sàn dispatch is a constant-time lookup once
# amendment-VN promotes and Bar carries a sàn field.
_TOLERANCE_BY_SAN: dict[str, Decimal] = {
    "HOSE": Decimal("0.01"),
    "HNX": Decimal("0.02"),
    "UPCOM": Decimal("0.05"),
}


class ReconciliationConfidence(StrEnum):
    """Confidence taxonomy for a reconciled price point."""

    HIGH = "high"
    LOW = "low"
    SINGLE_SOURCE = "single_source"


@dataclass(frozen=True, slots=True)
class ReconciledBar:
    """View row over two source Bars at the same (ticker, period_end) key."""

    ticker: Ticker
    period_end: date
    close_reconciled: Money
    confidence: ReconciliationConfidence
    divergence_pct: Decimal
    sources_present: tuple[SourceProvider, ...]
    close_by_source: dict[SourceProvider, Money]


@dataclass
class ReconciliationService:
    """Stateless cross-source Bar reconciler. Construct once, call `reconcile`."""

    tolerance: Decimal = _DEFAULT_TOLERANCE

    def tolerance_for(self, bar: Bar) -> Decimal:
        """Return the reconciliation tolerance applicable to `bar`.

        Phase 2 / S33: Bar entity does not yet carry a `sàn` field
        (amendment-VN Rule 14 PROPOSAL only); VN30 = HOSE-only by construction
        so the HOSE baseline ±1% applies uniformly. Once amendment-VN promotes
        and Bar gains `sàn`, this method dispatches via `_TOLERANCE_BY_SAN`.
        Until then it returns the service-level `self.tolerance` so per-call
        overrides remain testable.
        """
        san = getattr(bar, "sàn", None) or getattr(bar, "san", None)
        if isinstance(san, str):
            return _TOLERANCE_BY_SAN.get(san.upper(), self.tolerance)
        return self.tolerance

    def reconcile(
        self,
        primary: list[Bar],
        secondary: list[Bar],
    ) -> list[ReconciledBar]:
        """Emit one ReconciledBar per unique (ticker, period_end) across inputs.

        Inputs are not assumed sorted; the service builds (ticker, period_end)
        index per source and walks the union of keys ascending by period_end
        within each ticker. `primary` is treated as the leading provider
        (vnstock in S28); `secondary` is the cross-check (TCBS in S28).
        """
        primary_index = self._index(primary)
        secondary_index = self._index(secondary)
        all_keys = sorted(set(primary_index.keys()) | set(secondary_index.keys()))

        out: list[ReconciledBar] = []
        for key in all_keys:
            ticker, period_end = key
            p = primary_index.get(key)
            s = secondary_index.get(key)
            out.append(self._reconcile_single(ticker, period_end, p, s))
        return out

    def _reconcile_single(
        self,
        ticker: Ticker,
        period_end: date,
        primary_bar: Bar | None,
        secondary_bar: Bar | None,
    ) -> ReconciledBar:
        if primary_bar is not None and secondary_bar is not None:
            divergence = self._divergence_pct(primary_bar.close, secondary_bar.close)
            if divergence <= self.tolerance:
                close_reconciled = self._mean(primary_bar.close, secondary_bar.close)
                confidence = ReconciliationConfidence.HIGH
            else:
                close_reconciled = primary_bar.close
                confidence = ReconciliationConfidence.LOW
            return ReconciledBar(
                ticker=ticker,
                period_end=period_end,
                close_reconciled=close_reconciled,
                confidence=confidence,
                divergence_pct=divergence,
                sources_present=(primary_bar.source_provider, secondary_bar.source_provider),
                close_by_source={
                    primary_bar.source_provider: primary_bar.close,
                    secondary_bar.source_provider: secondary_bar.close,
                },
            )
        present = primary_bar or secondary_bar
        assert present is not None  # one must be set per all_keys construction
        return ReconciledBar(
            ticker=ticker,
            period_end=period_end,
            close_reconciled=present.close,
            confidence=ReconciliationConfidence.SINGLE_SOURCE,
            divergence_pct=Decimal("0"),
            sources_present=(present.source_provider,),
            close_by_source={present.source_provider: present.close},
        )

    @staticmethod
    def _divergence_pct(a: Money, b: Money) -> Decimal:
        if a.currency != b.currency:
            raise CurrencyMismatchError(a.currency, b.currency)
        max_abs = max(a.amount, b.amount)
        if max_abs == 0:
            return Decimal("0")
        return abs(a.amount - b.amount) / max_abs

    @staticmethod
    def _mean(a: Money, b: Money) -> Money:
        if a.currency != b.currency:
            raise CurrencyMismatchError(a.currency, b.currency)
        return Money((a.amount + b.amount) / Decimal("2"), a.currency)

    @staticmethod
    def _index(bars: list[Bar]) -> dict[tuple[Ticker, date], Bar]:
        return {(b.ticker, b.period_end): b for b in bars}
