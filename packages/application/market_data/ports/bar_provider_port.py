"""BarProviderPort — application-layer port for external Bar source adapters.

Per architecture.md § Layer Hierarchy: application defines Protocols;
infrastructure implements them. Adapters at packages/infrastructure/market_data/
(VnstockAdapter, TcbsAdapter) satisfy this Protocol. The S28 reconciliation
service consumes Bar lists from two providers via this port.

Distinct from BarRepository (S27 domain Protocol) which is the *read*
interface for persisted Bars; BarProviderPort is the *fetch* interface for
external sources before persistence per Rule 4 (source attribution).
"""

from __future__ import annotations

from datetime import date
from typing import Protocol

from packages.contracts import Ticker
from packages.domain.market_data.models import Bar

__all__ = ["BarProviderPort"]


class BarProviderPort(Protocol):
    """Adapter contract: fetch DAILY OHLCV bars for a ticker over a date range.

    Phase 1 thin-slice supports DAILY only. Intraday timeframes deferred to
    Phase 2 (per spec 000 § A.5). Adapters set Bar.source_provider per their
    SourceProvider Enum value (VNSTOCK | TCBS | etc.) so reconciliation can
    distinguish provenance per Rule 4.
    """

    def fetch_daily(self, ticker: Ticker, start: date, end: date) -> list[Bar]:
        """Return Bars with period_end in [start, end], sorted ascending.

        Adapters MAY return fewer bars than expected if the source has gaps
        (suspension, missing data); reconciliation handles divergence. They
        MUST raise on transport errors — silent empty list = bug per
        agent-notes "stale data must propagate".
        """
        ...
