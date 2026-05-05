"""Shared-kernel value objects + identifier types referenced across all 9 BCs.

Per IMPL-S27-1 (S27 session log): the strict cross-BC import rule
(architecture.md § Cross-BC Rules: "Never direct import between BCs") forces
ubiquitous value objects (Ticker, Money, AdjustmentType, SourceProvider) into
this shared-kernel layer rather than living in BC-1's value_objects/ directory
as the master-plan deliverable list described. This preserves BC-9 Position's
ability to type-hint `ticker: Ticker` and `cost_basis: Money` without importing
from packages.domain.market_data.

Identifier types (BarId, PositionId) are NewType aliases over str — runtime
strings, but mypy --strict enforces use-site type discipline so a BarId never
gets passed where a PositionId is expected.
"""

from .adjustment_type import AdjustmentType, SourceProvider
from .identifiers import BarId, PositionId, new_bar_id, new_position_id
from .money import Currency, CurrencyMismatchError, Money
from .price_snapshot import PriceSnapshot
from .ticker import InvalidTickerError, Ticker

__all__ = [
    "AdjustmentType",
    "BarId",
    "Currency",
    "CurrencyMismatchError",
    "InvalidTickerError",
    "Money",
    "PositionId",
    "PriceSnapshot",
    "SourceProvider",
    "Ticker",
    "new_bar_id",
    "new_position_id",
]
