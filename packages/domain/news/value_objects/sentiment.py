"""Sentiment — categorical 5-class enum per financial-data-protocol Rule 7.

Sentiment is NEVER numeric in the domain layer. Numeric aggregation
(e.g. `(bullish_count - bearish_count) / total_count`) happens in the
application layer with an explicit formula so backtests can audit which
scoring formula correlates with subsequent price moves.

Source: agent-workspace/constitution/financial-data-protocol.md Rule 7;
specs/tier1-strategic/001-four-tier-signal-architecture.md § B.2.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["Sentiment"]


class Sentiment(StrEnum):
    """Five-class categorical sentiment label.

    The lowercase token is what lands on disk via `.value`; the JSON / TSV
    serialisation matches StatementType / SourceProvider precedent.
    """

    STRONGLY_BULLISH = "strongly_bullish"
    BULLISH = "bullish"
    NEUTRAL = "neutral"
    BEARISH = "bearish"
    STRONGLY_BEARISH = "strongly_bearish"
