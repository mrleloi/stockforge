"""BC-2 Fundamental — financial reports + ratios + valuation inputs.

Phase 2 thin slice (S34 Track C): FinancialStatement entity + ratio + peer +
percentile services + FundamentalRepository Protocol. Earnings revisions,
restatement tracking, and DCF valuation deferred to Phase 3 per
spec-T1-001 § B.1 + master-plan 005 § S34.

Cross-BC types (Ticker, Money, Currency, SourceProvider) live in
packages/contracts/types/ per IMPL-S27-1; this package only declares
BC-2-private domain artifacts.
"""

from .models import FinancialStatement, FinancialStatementInvariantError
from .repositories import FundamentalRepository
from .services import (
    HistoricalPercentile,
    PeerService,
    PercentileService,
    RatioComputationError,
    RatioInputMissingError,
    RatioService,
)
from .value_objects import (
    LineItemKey,
    Ratio,
    RatioName,
    StatementType,
    line_item_required_for_ratio,
)

__all__ = [
    "FinancialStatement",
    "FinancialStatementInvariantError",
    "FundamentalRepository",
    "HistoricalPercentile",
    "LineItemKey",
    "PeerService",
    "PercentileService",
    "Ratio",
    "RatioComputationError",
    "RatioInputMissingError",
    "RatioName",
    "RatioService",
    "StatementType",
    "line_item_required_for_ratio",
]
