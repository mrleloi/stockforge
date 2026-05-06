"""EvaluateOutcomeReviewUseCase — orchestrates UC-2 (deterministic outcome evaluation).

NO LLM imports — outcome math is deterministic per Charter Principle 9 + I-S1.

Flow (spec § B.3 UC-2):
1. Load OutcomeReview + parent Recommendation.
2. BR-7: if recommendation has conditions, ask the condition_evaluator whether
   the condition was met during the review window.
   - condition not met → mark INVALID + persist + return.
3. Look up close prices via QuoteLookupPort:
   - price_at_rec  = close on (published_at + 1 calendar day) [next-day open assumption].
   - price_at_review = close on review.scheduled_at.date().
   - benchmark_return = VN-INDEX return over the same date range.
   - any None → leave PENDING (no destructive write); caller may retry tomorrow.
4. Compute return_pct + excess_return_pct deterministically (no LLM).
5. Delegate HIT/MISS/PARTIAL/INCONCLUSIVE classification to OutcomeEvaluator.
6. Persist; return updated review. Caller may chain UpdateKolCredibilityUseCase
   when window == THREE_MONTH per spec § UC-2 trigger.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.3 UC-2 + § A.3 BR-7.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § e).
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from typing import Protocol

from packages.application.influence.ports.benchmark_service_port import (
    BenchmarkServicePort,
)
from packages.application.influence.ports.outcome_review_repository_port import (
    OutcomeReviewRepositoryPort,
)
from packages.application.influence.ports.quote_lookup_port import QuoteLookupPort
from packages.application.influence.ports.recommendation_repository_port import (
    RecommendationRepositoryPort,
)
from packages.domain.influence.models.outcome_review import OutcomeReview
from packages.domain.influence.services.outcome_evaluator import OutcomeEvaluator

__all__ = ["ConditionEvaluator", "EvaluateOutcomeReviewUseCase"]


class ConditionEvaluator(Protocol):
    """BR-7 hook: evaluate whether a list of natural-language conditions ever met.

    Implementations may use a deterministic rule engine (preferred) OR an
    auxiliary deterministic check against price-action history. LLM inference
    is acceptable here ONLY when the LLM's output is a boolean condition-met
    flag, not a number — but Phase 3 stub returns False for safety so unmet
    conditions land INVALID instead of polluting the calibration.
    """

    async def was_condition_met(
        self,
        *,
        conditions: list[str],
        ticker: str,
        from_date: datetime,
        to_date: datetime,
    ) -> bool:
        ...


class _OutcomeNotReadyError(RuntimeError):
    """Raised internally when prices are missing — leave review PENDING."""


class EvaluateOutcomeReviewUseCase:
    """Run a single due OutcomeReview to terminal status."""

    def __init__(
        self,
        *,
        review_repo: OutcomeReviewRepositoryPort,
        recommendation_repo: RecommendationRepositoryPort,
        quote_lookup: QuoteLookupPort,
        benchmark_service: BenchmarkServicePort,
        outcome_evaluator: OutcomeEvaluator,
        condition_evaluator: ConditionEvaluator | None = None,
    ) -> None:
        self._review_repo = review_repo
        self._recommendation_repo = recommendation_repo
        self._quote_lookup = quote_lookup
        self._benchmark_service = benchmark_service
        self._outcome_evaluator = outcome_evaluator
        self._condition_evaluator = condition_evaluator

    async def execute(self, review_id: str) -> OutcomeReview | None:
        """Evaluate one review.

        Returns the updated review on success, or the unmodified review when
        prices are missing (PENDING preserved for tomorrow's cron pass).
        Returns None when the review is not found.
        """
        review = await self._review_repo.get(review_id)
        if review is None:
            return None
        if not review.is_pending():
            return review

        rec = await self._recommendation_repo.get(review.recommendation_id)
        if rec is None:
            return review

        if rec.is_conditional():
            if self._condition_evaluator is None:
                review.mark_invalid(
                    reason="Conditional recommendation but no condition_evaluator wired"
                )
                await self._review_repo.save(review)
                return review
            condition_met = await self._condition_evaluator.was_condition_met(
                conditions=rec.conditions,
                ticker=rec.ticker,
                from_date=rec.published_at,
                to_date=review.scheduled_at,
            )
            if not condition_met:
                review.mark_invalid(reason="Condition never met during review period")
                await self._review_repo.save(review)
                return review

        rec_eval_date = (rec.published_at + timedelta(days=1)).date()
        review_eval_date = review.scheduled_at.date()

        price_at_rec = await self._quote_lookup.get_close_on(
            ticker=rec.ticker, on=rec_eval_date
        )
        price_at_review = await self._quote_lookup.get_close_on(
            ticker=rec.ticker, on=review_eval_date
        )
        benchmark_return = await self._benchmark_service.get_index_return(
            index="VN-INDEX", from_date=rec_eval_date, to_date=review_eval_date
        )

        if price_at_rec is None or price_at_review is None or benchmark_return is None:
            return review
        if price_at_rec <= 0:
            return review

        return_pct = (price_at_review - price_at_rec) / price_at_rec
        excess_return = return_pct - benchmark_return

        status = self._outcome_evaluator.evaluate(
            intent=rec.intent,
            timeframe=rec.timeframe,
            excess_return=excess_return,
        )

        review.mark_evaluated(
            status=status,
            price_at_rec_vnd=price_at_rec,
            price_at_review_vnd=price_at_review,
            return_pct=return_pct,
            benchmark_return_pct=benchmark_return,
            excess_return_pct=excess_return,
            completed_at=datetime.now(UTC),
        )
        await self._review_repo.save(review)
        return review
