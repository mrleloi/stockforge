"""BC-1 Market Data — time-series price/volume + foreign flow.

Phase 1 thin-slice (S27): Bar entity + BarRepository Protocol. Intraday +
ForeignFlow + OrderBook + MarketRegime aggregates per architecture.md § BC-1
deferred to Phase 2.

Cross-BC types (Ticker, Money, AdjustmentType, SourceProvider, BarId) live in
packages/contracts/types/ per IMPL-S27-1 (S27 session log) — strict reading
of architecture.md § Cross-BC Rules forbids BC-9 from importing BC-1 types
directly.
"""

from .models import Bar, BarInvariantError
from .repositories import BarRepository
from .value_objects import VN30_UNIVERSE, Vn30Constituent, vn30_tickers

__all__ = [
    "VN30_UNIVERSE",
    "Bar",
    "BarInvariantError",
    "BarRepository",
    "Vn30Constituent",
    "vn30_tickers",
]
