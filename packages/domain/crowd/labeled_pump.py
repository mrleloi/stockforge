"""LabeledPump — aggregate for historical labeled pump events (BC-7 BR-5 backtest gate).

Used to build evaluation set for PumpPhaseClassifier holdout validation.
Seeded manually per spec § B.7: user labels 5-10 historical pump events from 2021-2024 VN market.

Invariants (D-032 § c + § i):
- period_end must be after period_start
- phases must be non-empty (list of phase strings representing the pump lifecycle)
- labeled_by must be 'user' or 'agent_with_review'

Storage: eval-sets/labeled-pumps/ directory per spec § B.7 + SQLite labeled_pumps table.
Holdout: 70/30 train/holdout split for BR-5 backtest gate.

I-S2: period_start + period_end provide provenance for historical data.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1 + § B.5 + § B.7.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § c + i).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Literal

__all__ = ["LabeledPump"]

LabeledBy = Literal["user", "agent_with_review"]

_VALID_LABELED_BY: frozenset[str] = frozenset({"user", "agent_with_review"})


@dataclass(frozen=True)
class LabeledPump:
    """Historical labeled pump event for backtest validation.

    features_at_detection: dict-like snapshot of TickerSignals at detection time.
    subsequent_outcome: filled post-hoc (30d/90d review window per D-032 § i).
    phases: ordered list of phase strings (e.g. ["pre_pump", "pump", "distribution"]).

    I-10: ZERO framework dependencies.
    """

    ticker: str
    period_start: datetime
    period_end: datetime
    phases: tuple[str, ...]           # ordered phase sequence during this pump event
    features_at_detection: dict[str, object]  # signal values at point of detection
    subsequent_outcome: str | None     # post-hoc outcome (filled 30d/90d after)
    labeled_by: LabeledBy

    def __post_init__(self) -> None:
        if self.period_end <= self.period_start:
            raise ValueError(
                f"LabeledPump.period_end must be after period_start; "
                f"got period_start={self.period_start!r}, period_end={self.period_end!r}"
            )
        if not self.phases:
            raise ValueError("LabeledPump.phases must be non-empty")
        if self.labeled_by not in _VALID_LABELED_BY:
            raise ValueError(
                f"LabeledPump.labeled_by must be one of {sorted(_VALID_LABELED_BY)}; "
                f"got {self.labeled_by!r}"
            )
        if not self.ticker:
            raise ValueError("LabeledPump.ticker must not be empty")
