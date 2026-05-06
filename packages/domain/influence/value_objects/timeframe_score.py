"""TimeframeScore — per-timeframe credibility disaggregation (BR-5).

A KOL may be accurate on long-horizon calls but weak on intraday. TimeframeScore
captures per-timeframe posterior mean + sample size symmetric to SectorScore.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § A.3 BR-5.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § e).
"""

from __future__ import annotations

from dataclasses import dataclass

from packages.domain.influence.value_objects.timeframe import Timeframe

__all__ = ["TimeframeScore"]


_MIN_SAMPLES_FOR_MEANINGFUL = 5


@dataclass(frozen=True, slots=True)
class TimeframeScore:
    """Disaggregated credibility for one Timeframe.

    Fields:
        timeframe         Timeframe enum value.
        n_evaluated       Outcome reviews completed within this timeframe.
        hit_rate_mean     Posterior mean (0-1) of hit-rate within this timeframe.
    """

    timeframe: Timeframe
    n_evaluated: int
    hit_rate_mean: float

    def __post_init__(self) -> None:
        if self.n_evaluated < 0:
            raise ValueError(
                f"TimeframeScore.n_evaluated must be >=0; got {self.n_evaluated}"
            )
        if not (0.0 <= self.hit_rate_mean <= 1.0):
            raise ValueError(
                f"TimeframeScore.hit_rate_mean must be in [0,1]; got {self.hit_rate_mean}"
            )

    def is_meaningful(self) -> bool:
        """True when sample size is large enough to act on per-timeframe signal."""
        return self.n_evaluated >= _MIN_SAMPLES_FOR_MEANINGFUL
