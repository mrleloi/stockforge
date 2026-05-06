"""SectorScore — per-sector credibility disaggregation (BR-5).

A KOL may be calibrated overall but skewed within sectors (e.g. accurate on
banking, weak on real-estate). SectorScore captures the per-sector hit-rate
mean + sample size so callers can downweight a recommendation when its sector
sample is too thin.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § A.3 BR-5.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § e).
"""

from __future__ import annotations

from dataclasses import dataclass

__all__ = ["SectorScore"]


_MIN_SAMPLES_FOR_MEANINGFUL = 5


@dataclass(frozen=True, slots=True)
class SectorScore:
    """Disaggregated credibility for one sector code.

    Fields:
        sector            VN sector code (e.g. "banking", "realestate", "energy").
        n_evaluated       Outcome reviews evaluated within this sector.
        hit_rate_mean     Posterior mean (0-1) of hit-rate within this sector.

    `is_meaningful()` returns True when the per-sector sample reaches the
    threshold below which posterior CI is too wide to act on.
    """

    sector: str
    n_evaluated: int
    hit_rate_mean: float

    def __post_init__(self) -> None:
        if not self.sector or not self.sector.strip():
            raise ValueError("SectorScore.sector must be a non-empty code")
        if self.n_evaluated < 0:
            raise ValueError(
                f"SectorScore.n_evaluated must be >=0; got {self.n_evaluated}"
            )
        if not (0.0 <= self.hit_rate_mean <= 1.0):
            raise ValueError(
                f"SectorScore.hit_rate_mean must be in [0,1]; got {self.hit_rate_mean}"
            )

    def is_meaningful(self) -> bool:
        """True when sample size is large enough to act on per-sector signal."""
        return self.n_evaluated >= _MIN_SAMPLES_FOR_MEANINGFUL
