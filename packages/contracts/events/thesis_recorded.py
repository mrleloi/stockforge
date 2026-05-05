"""ThesisRecorded — BC-8 emits when a thesis is persisted.

Cross-BC contract event. Per cross-BC tolerance principle (from
extracted_claim_published.py): recommendation and confidence_level are raw str
(NOT domain enums). Downstream consumers validate against their own enum copies
without importing BC-8 domain types.

thesis_id is the deterministic sha256 ID (AC-5 reproducibility).
cost_usd is Decimal — NEVER float for currency per CLAUDE.md hard rule.

Phase 2: synchronous in-process EventBus. Phase 4+: Redis Streams / Dramatiq.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.8.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal

from packages.contracts.types import Ticker

__all__ = ["ThesisRecorded"]

_VALID_RECOMMENDATIONS = frozenset(
    {"thesis_candidate", "investigate", "watch", "pass"}
)

_VALID_CONFIDENCE_LEVELS = frozenset({"high", "medium", "low"})


@dataclass(frozen=True, slots=True)
class ThesisRecorded:
    """Past-tense fact: a thesis was validated and persisted.

    recommendation and confidence_level are raw str per cross-BC tolerance
    (consumers validate locally; no BC-8 domain imports required).
    """

    thesis_id: str
    ticker: Ticker
    as_of: date
    recommendation: str       # raw str — see Recommendation enum in BC-8
    confidence_level: str     # raw str — see ConfidenceLevel enum in BC-8
    cost_usd: Decimal
    recorded_at: datetime

    def __post_init__(self) -> None:
        if not self.thesis_id.strip():
            raise ValueError("thesis_id is required (ThesisRecorded)")
        if self.recommendation not in _VALID_RECOMMENDATIONS:
            raise ValueError(
                f"recommendation {self.recommendation!r} not in "
                f"{sorted(_VALID_RECOMMENDATIONS)}"
            )
        if self.confidence_level not in _VALID_CONFIDENCE_LEVELS:
            raise ValueError(
                f"confidence_level {self.confidence_level!r} not in "
                f"{sorted(_VALID_CONFIDENCE_LEVELS)}"
            )
        if self.cost_usd < Decimal("0"):
            raise ValueError(
                f"cost_usd cannot be negative: {self.cost_usd}"
            )
