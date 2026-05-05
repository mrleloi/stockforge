"""Cross-BC contract layer — shared kernel value objects + events + commands.

Per agent-workspace/constitution/architecture.md § Cross-BC Rules:
- Cross-BC types live in packages/contracts/.
- Cross-BC events defined in packages/contracts/events/.
- Cross-BC commands defined in packages/contracts/commands/.

Phase 1 thin-slice (S27):
- types/: Ticker, Money, Currency, AdjustmentType, SourceProvider, BarId, PositionId
- events/: position_value_computed (BC-9 emits when Position re-prices from Bar)

Pure stdlib + dataclasses + Enum. Zero framework dependency (matches
agent-workspace/CLAUDE.md hard rule "Domain layer has ZERO framework dependency").
"""

from .events.extracted_claim_published import ExtractedClaimPublished
from .events.financial_statement_filed import FinancialStatementFiled
from .events.news_article_ingested import NewsArticleIngested
from .events.position_value_computed import PositionValueComputed
from .types import (
    AdjustmentType,
    BarId,
    Currency,
    CurrencyMismatchError,
    InvalidTickerError,
    Money,
    PositionId,
    PriceSnapshot,
    SourceProvider,
    Ticker,
    new_bar_id,
    new_position_id,
)

__all__ = [
    "AdjustmentType",
    "BarId",
    "Currency",
    "CurrencyMismatchError",
    "ExtractedClaimPublished",
    "FinancialStatementFiled",
    "InvalidTickerError",
    "Money",
    "NewsArticleIngested",
    "PositionId",
    "PositionValueComputed",
    "PriceSnapshot",
    "SourceProvider",
    "Ticker",
    "new_bar_id",
    "new_position_id",
]
