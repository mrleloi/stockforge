"""CalibrationService — Bayesian credibility computation (UC-3, deterministic).

DETERMINISTIC ONLY — NO LLM IMPORTS PERMITTED IN THIS MODULE.

Per Charter Principle 9 (NO LLM math) + I-S1 (CRITICAL invariant): the LLM may
NEVER produce credibility numbers. This service computes them from completed
OutcomeReview data with traceable inputs (HIT/MISS/PARTIAL counts) using the
scipy.stats.beta posterior distribution + a skeptical Beta(5, 5) prior.

Algorithm (spec § B.3 UC-3 verbatim):
1. Bucket reviews into n_hits / n_misses / n_partial.
   INVALID + INCONCLUSIVE are excluded from buckets but still count toward
   n_evaluated for the BR-2 PROVISIONAL→ACTIVE gate.
2. Weight PARTIAL as 0.5 success.
   n_total_weighted   = n_hits + n_misses + n_partial
   n_success_weighted = n_hits + 0.5 * n_partial
3. Posterior:
   posterior_alpha = 5 + n_success_weighted
   posterior_beta  = 5 + (n_total_weighted - n_success_weighted)
4. Mean = alpha / (alpha + beta); 90% CI via scipy.stats.beta.ppf(0.05/0.95).
5. Sector + timeframe disaggregation per BR-5 (each cell uses the same prior).

The Beta(5, 5) prior dampens small-sample optimism: 3 hits / 0 misses returns
posterior_mean ≈ 0.62 (NOT 1.0) because the prior contributes 5 prior-success +
5 prior-failure pseudo-counts.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.3 UC-3 + § A.3 BR-2 + BR-5.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § e).
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from datetime import UTC, datetime

from scipy.stats import beta as _scipy_beta

from packages.domain.influence.models.credibility_score import CredibilityScore
from packages.domain.influence.models.outcome_review import (
    OutcomeReview,
    OutcomeStatus,
)
from packages.domain.influence.models.recommendation import Recommendation
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.recommendation_id import RecommendationId
from packages.domain.influence.value_objects.sector_score import SectorScore
from packages.domain.influence.value_objects.timeframe import Timeframe
from packages.domain.influence.value_objects.timeframe_score import TimeframeScore

__all__ = ["CalibrationResult", "CalibrationService"]


# Spec § B.3 UC-3: skeptical Beta(5, 5) prior — weakly informative, mean=0.5,
# dampens small-sample swings (n=3 cannot drive posterior to 1.0).
_PRIOR_ALPHA = 5.0
_PRIOR_BETA = 5.0

# Spec § B.1 CredibilityScore: 90% credibility interval (5th + 95th pct).
_CI_LOWER_QUANTILE = 0.05
_CI_UPPER_QUANTILE = 0.95


@dataclass(frozen=True, slots=True)
class CalibrationResult:
    """Side-channel snapshot of the raw counts used for credibility computation.

    Useful for tests + audit logs that want to see the buckets separately from
    the posterior aggregate.
    """

    n_evaluated: int
    n_hits: int
    n_misses: int
    n_partial: int
    n_invalid: int
    n_inconclusive: int


class CalibrationService:
    """Stateless deterministic Bayesian credibility computer.

    Methods take fully-resolved domain objects + return a new CredibilityScore
    aggregate. Persistence is the caller's responsibility (see UC-3 use case).

    The scipy.stats.beta dependency is the ONLY external dep; no LLM imports.
    """

    def compute(
        self,
        *,
        kol_id: KolId,
        reviews: list[OutcomeReview],
        recommendations_by_id: dict[RecommendationId, Recommendation] | None = None,
        sectors_by_recommendation: dict[RecommendationId, str] | None = None,
        as_of: datetime | None = None,
    ) -> CredibilityScore:
        """Compute the posterior credibility for one KOL from their reviews.

        Args:
            kol_id: KOL whose credibility is being computed.
            reviews: ALL completed OutcomeReview rows for this KOL.
            recommendations_by_id: optional {RecommendationId -> Recommendation}
                map used for per-timeframe disaggregation. When omitted the
                returned score has empty timeframe_scores.
            sectors_by_recommendation: optional {RecommendationId -> sector_code}
                map used for per-sector disaggregation. When omitted the
                returned score has empty sector_scores.
            as_of: timestamp for last_updated_at; defaults to now(UTC).

        Returns:
            CredibilityScore aggregate. Cold-start (0 reviews) yields the prior
            mean of 0.5 with a wide CI.
        """
        counts = self._bucket(reviews)
        post_alpha, post_beta = self._posterior(counts)
        mean = post_alpha / (post_alpha + post_beta)
        ci_low = float(_scipy_beta.ppf(_CI_LOWER_QUANTILE, post_alpha, post_beta))
        ci_high = float(_scipy_beta.ppf(_CI_UPPER_QUANTILE, post_alpha, post_beta))

        timeframe_scores: dict[Timeframe, TimeframeScore] = {}
        sector_scores: dict[str, SectorScore] = {}
        if recommendations_by_id:
            timeframe_scores = self._compute_timeframe_scores(
                reviews, recommendations_by_id
            )
        if sectors_by_recommendation:
            sector_scores = self._compute_sector_scores(
                reviews, sectors_by_recommendation
            )

        return CredibilityScore(
            kol_id=kol_id,
            n_evaluated=counts.n_evaluated,
            n_hits=counts.n_hits,
            n_misses=counts.n_misses,
            n_partial=counts.n_partial,
            posterior_alpha=post_alpha,
            posterior_beta=post_beta,
            bayesian_mean=mean,
            bayesian_ci_low=ci_low,
            bayesian_ci_high=ci_high,
            sector_scores=sector_scores,
            timeframe_scores=timeframe_scores,
            last_updated_at=as_of if as_of is not None else datetime.now(UTC),
        )

    @staticmethod
    def _bucket(reviews: list[OutcomeReview]) -> CalibrationResult:
        n_hits = sum(1 for r in reviews if r.status == OutcomeStatus.HIT)
        n_misses = sum(1 for r in reviews if r.status == OutcomeStatus.MISS)
        n_partial = sum(1 for r in reviews if r.status == OutcomeStatus.PARTIAL)
        n_invalid = sum(1 for r in reviews if r.status == OutcomeStatus.INVALID)
        n_inconclusive = sum(
            1 for r in reviews if r.status == OutcomeStatus.INCONCLUSIVE
        )
        return CalibrationResult(
            n_evaluated=len(reviews),
            n_hits=n_hits,
            n_misses=n_misses,
            n_partial=n_partial,
            n_invalid=n_invalid,
            n_inconclusive=n_inconclusive,
        )

    @staticmethod
    def _posterior(counts: CalibrationResult) -> tuple[float, float]:
        n_total_weighted = counts.n_hits + counts.n_misses + counts.n_partial
        n_success_weighted = counts.n_hits + 0.5 * counts.n_partial
        post_alpha = _PRIOR_ALPHA + n_success_weighted
        post_beta = _PRIOR_BETA + (n_total_weighted - n_success_weighted)
        return post_alpha, post_beta

    def _compute_timeframe_scores(
        self,
        reviews: list[OutcomeReview],
        recommendations_by_id: dict[RecommendationId, Recommendation],
    ) -> dict[Timeframe, TimeframeScore]:
        groups: dict[Timeframe, list[OutcomeReview]] = defaultdict(list)
        for r in reviews:
            rec = recommendations_by_id.get(r.recommendation_id)
            if rec is None:
                continue
            groups[rec.timeframe].append(r)
        result: dict[Timeframe, TimeframeScore] = {}
        for tf, tf_reviews in groups.items():
            counts = self._bucket(tf_reviews)
            alpha, beta_param = self._posterior(counts)
            mean = alpha / (alpha + beta_param)
            result[tf] = TimeframeScore(
                timeframe=tf,
                n_evaluated=counts.n_evaluated,
                hit_rate_mean=mean,
            )
        return result

    def _compute_sector_scores(
        self,
        reviews: list[OutcomeReview],
        sectors_by_recommendation: dict[RecommendationId, str],
    ) -> dict[str, SectorScore]:
        groups: dict[str, list[OutcomeReview]] = defaultdict(list)
        for r in reviews:
            sector = sectors_by_recommendation.get(r.recommendation_id)
            if sector is None or not sector.strip():
                continue
            groups[sector].append(r)
        result: dict[str, SectorScore] = {}
        for sector, sec_reviews in groups.items():
            counts = self._bucket(sec_reviews)
            alpha, beta_param = self._posterior(counts)
            mean = alpha / (alpha + beta_param)
            result[sector] = SectorScore(
                sector=sector,
                n_evaluated=counts.n_evaluated,
                hit_rate_mean=mean,
            )
        return result
