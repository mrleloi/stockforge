"""CounterNarrativeGenerated — cross-BC event for contrarian analysis completion (BC-7).

Fired by GenerateCounterNarrativeUseCase (UC-4) after BR-6 mandatory trigger.
Consumers: BC-4 (Portfolio/Risk — alert on hot-stock consensus), BC-9 (Position Sizing).

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-4.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § b + g).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

__all__ = ["CounterNarrativeGenerated"]


@dataclass(frozen=True)
class CounterNarrativeGenerated:
    """Cross-BC event: a counter-narrative has been generated for a hot-stock ticker.

    BR-6 mandatory: always generated when bullish_ratio() > 0.8.
    Consumers use this as an advisory flag — research context, not trade signal.
    """

    ticker: str
    trigger: str             # e.g. "bullish_ratio_threshold_crossed"
    bear_points_count: int   # number of bear-point strings generated
    historical_analogs_count: int  # number of historical analogs found
    generated_at: datetime
