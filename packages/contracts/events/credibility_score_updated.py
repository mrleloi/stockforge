"""CredibilityScoreUpdated — BC-6 emits after a Bayesian credibility recompute.

Cross-BC contract event. Downstream consumers (BC-8 Analysis for thesis
weighting; future BC-7 confluence detector) use this to refresh their
in-memory credibility caches without polling. Per spec § B.2.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

__all__ = ["CredibilityScoreUpdated"]


@dataclass(frozen=True, slots=True)
class CredibilityScoreUpdated:
    """Event emitted by UC-3 after a successful credibility recompute.

    Carries old + new posterior means so subscribers can detect material
    moves (e.g. >0.05 swing triggers re-rank in confluence detection).
    """

    kol_id: str
    old_bayesian_mean: float | None
    new_bayesian_mean: float
    n_evaluated: int
    updated_at: datetime
    posterior_alpha: float
    posterior_beta: float
