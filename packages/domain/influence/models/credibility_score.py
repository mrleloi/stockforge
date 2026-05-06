"""CredibilityScore — BC-6 per-KOL Bayesian credibility aggregate.

Holds the posterior Beta(alpha, beta) parameters for a KOL plus the derived
mean + 90% CI plus per-sector + per-timeframe disaggregations.

Construction-time invariants:
- n_hits + n_misses + n_partial == n_evaluated cannot exceed n_evaluated count
  (n_evaluated may be larger because INVALID/INCONCLUSIVE reviews are excluded
  from hit/miss/partial buckets).
- posterior_alpha + posterior_beta strictly > 0 (Beta distribution undefined
  otherwise).
- bayesian_mean in [0, 1]; bayesian_ci_low <= bayesian_ci_high; both in [0, 1].

`is_statistically_meaningful()` returns True when the 90% CI width is below the
0.15 threshold per spec § B.1 — i.e. the posterior is tight enough to act on.
`is_high_credibility()` returns True when the posterior mean is at least 0.6
AND the score is statistically meaningful (per spec § B.1 + UC-4 confluence
gate).

NO LLM imports permitted in this module — credibility numbers are deterministic
code output per I-S1 (NO LLM math).

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § B.3 UC-3.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § e).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime

from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.sector_score import SectorScore
from packages.domain.influence.value_objects.timeframe import Timeframe
from packages.domain.influence.value_objects.timeframe_score import TimeframeScore

__all__ = ["CredibilityScore", "InvariantViolation"]


# Spec § B.1: posterior is statistically meaningful when the 90% CI width is
# below this threshold — wider intervals mean the sample is too thin to act on.
_CI_WIDTH_MEANINGFUL_THRESHOLD = 0.15

# Spec § B.1: high-credibility threshold for confluence detection (UC-4).
_HIGH_CREDIBILITY_MEAN_THRESHOLD = 0.6


class InvariantViolation(ValueError):
    """Raised when CredibilityScore construction violates a domain invariant."""


@dataclass
class CredibilityScore:
    """KOL credibility aggregate (Bayesian posterior + disaggregations).

    See module docstring for invariant details.

    `n_evaluated` is the total number of outcome reviews considered (including
    those that landed INVALID / INCONCLUSIVE — which are excluded from
    hit/miss/partial buckets but still counted toward sample size for
    BR-2 PROVISIONAL→ACTIVE transition).
    """

    kol_id: KolId
    n_evaluated: int
    n_hits: int
    n_misses: int
    n_partial: int
    posterior_alpha: float
    posterior_beta: float
    bayesian_mean: float
    bayesian_ci_low: float
    bayesian_ci_high: float
    last_updated_at: datetime
    sector_scores: dict[str, SectorScore] = field(default_factory=dict)
    timeframe_scores: dict[Timeframe, TimeframeScore] = field(default_factory=dict)

    def __post_init__(self) -> None:
        if self.n_evaluated < 0:
            raise InvariantViolation(
                f"n_evaluated must be >=0; got {self.n_evaluated}"
            )
        for label, value in (
            ("n_hits", self.n_hits),
            ("n_misses", self.n_misses),
            ("n_partial", self.n_partial),
        ):
            if value < 0:
                raise InvariantViolation(f"{label} must be >=0; got {value}")
        bucketed = self.n_hits + self.n_misses + self.n_partial
        if bucketed > self.n_evaluated:
            raise InvariantViolation(
                f"n_hits+n_misses+n_partial ({bucketed}) cannot exceed "
                f"n_evaluated ({self.n_evaluated})"
            )
        if self.posterior_alpha <= 0 or self.posterior_beta <= 0:
            raise InvariantViolation(
                f"posterior_alpha and posterior_beta must be >0; "
                f"got alpha={self.posterior_alpha}, beta={self.posterior_beta}"
            )
        if not (0.0 <= self.bayesian_mean <= 1.0):
            raise InvariantViolation(
                f"bayesian_mean must be in [0,1]; got {self.bayesian_mean}"
            )
        for label, ci_value in (
            ("bayesian_ci_low", self.bayesian_ci_low),
            ("bayesian_ci_high", self.bayesian_ci_high),
        ):
            if not (0.0 <= ci_value <= 1.0):
                raise InvariantViolation(f"{label} must be in [0,1]; got {ci_value}")
        if self.bayesian_ci_low > self.bayesian_ci_high:
            raise InvariantViolation(
                f"bayesian_ci_low ({self.bayesian_ci_low}) must be <= "
                f"bayesian_ci_high ({self.bayesian_ci_high})"
            )

    def is_statistically_meaningful(self) -> bool:
        """True when the posterior 90% CI is tight enough to act on."""
        return (self.bayesian_ci_high - self.bayesian_ci_low) < _CI_WIDTH_MEANINGFUL_THRESHOLD

    def is_high_credibility(self) -> bool:
        """True when the posterior is high AND statistically meaningful (spec § B.1)."""
        return (
            self.bayesian_mean >= _HIGH_CREDIBILITY_MEAN_THRESHOLD
            and self.is_statistically_meaningful()
        )

    @property
    def ci_width(self) -> float:
        """90% credibility-interval width (smaller = more confident)."""
        return self.bayesian_ci_high - self.bayesian_ci_low
