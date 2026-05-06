"""OutcomeReview — BC-6 per-recommendation outcome evaluation aggregate.

Each KOL Recommendation is paired with 4 OutcomeReview rows (one per
ReviewWindow: 1m / 3m / 6m / 12m). The scheduler writes them with status
PENDING + due_at = published_at + window_offset; a daily cron picks due
reviews and the EvaluateOutcomeReviewUseCase populates price_at_rec /
price_at_review / return_pct / status.

Status transitions are guarded:
- PENDING → HIT | MISS | PARTIAL | INVALID | INCONCLUSIVE  (via mark_evaluated /
  mark_invalid).
- Once non-PENDING, status is terminal — re-evaluation requires a new review_id.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § B.3 UC-2.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § f).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from enum import StrEnum

from packages.domain.influence.value_objects.recommendation_id import RecommendationId

__all__ = [
    "InvariantViolation",
    "OutcomeReview",
    "OutcomeStatus",
    "ReviewWindow",
    "window_offset",
]


class ReviewWindow(StrEnum):
    """Outcome review horizon.

    Spec § B.6: review_window CHECK constraint allows exactly these 4 values.
    """

    ONE_MONTH = "one_month"
    THREE_MONTH = "three_month"
    SIX_MONTH = "six_month"
    TWELVE_MONTH = "twelve_month"


class OutcomeStatus(StrEnum):
    """Outcome review status.

    Spec § B.1 enumerates 6 values:
        PENDING       — review not yet evaluated (default at scheduling).
        HIT           — recommendation matched expected outcome.
        MISS          — recommendation contradicted expected outcome.
        PARTIAL       — recommendation partially matched (half excess return).
        INVALID       — conditional recommendation whose condition never met (BR-7).
        INCONCLUSIVE  — informational call (e.g. WATCH) where HIT/MISS does not apply.
    """

    PENDING = "pending"
    HIT = "hit"
    MISS = "miss"
    PARTIAL = "partial"
    INVALID = "invalid"
    INCONCLUSIVE = "inconclusive"


_WINDOW_DAYS: dict[ReviewWindow, int] = {
    ReviewWindow.ONE_MONTH: 30,
    ReviewWindow.THREE_MONTH: 90,
    ReviewWindow.SIX_MONTH: 180,
    ReviewWindow.TWELVE_MONTH: 365,
}


def window_offset(window: ReviewWindow) -> timedelta:
    """Calendar-day offset for a ReviewWindow (used by the scheduler)."""
    return timedelta(days=_WINDOW_DAYS[window])


class InvariantViolation(ValueError):
    """Raised when an OutcomeReview transition or construction is invalid."""


@dataclass
class OutcomeReview:
    """OutcomeReview aggregate.

    `scheduled_at` is the *due_at* — the moment the review becomes ready for
    evaluation (published_at + window_offset). `completed_at` is set when the
    use case writes the final status. `notes` may carry the INVALID reason
    text per UC-2.
    """

    review_id: str
    recommendation_id: RecommendationId
    review_window: ReviewWindow
    scheduled_at: datetime
    status: OutcomeStatus = OutcomeStatus.PENDING
    completed_at: datetime | None = None
    price_at_rec_vnd: float | None = None
    price_at_review_vnd: float | None = None
    return_pct: float | None = None
    benchmark_return_pct: float | None = None
    excess_return_pct: float | None = None
    notes: str | None = None

    def __post_init__(self) -> None:
        if not self.review_id or not self.review_id.strip():
            raise InvariantViolation("OutcomeReview.review_id must be non-empty")
        if self.status != OutcomeStatus.PENDING and self.completed_at is None:
            raise InvariantViolation(
                f"OutcomeReview with status {self.status} must have completed_at set"
            )

    def is_pending(self) -> bool:
        return self.status == OutcomeStatus.PENDING

    def is_terminal(self) -> bool:
        """True when the review has reached a final status (not PENDING)."""
        return self.status != OutcomeStatus.PENDING

    def is_due(self, *, as_of: datetime | None = None) -> bool:
        """True when the review is PENDING and scheduled_at is in the past."""
        now = as_of if as_of is not None else datetime.now(UTC)
        scheduled = self.scheduled_at
        if scheduled.tzinfo is None:
            scheduled = scheduled.replace(tzinfo=UTC)
        if now.tzinfo is None:
            now = now.replace(tzinfo=UTC)
        return self.is_pending() and scheduled <= now

    def mark_evaluated(
        self,
        *,
        status: OutcomeStatus,
        price_at_rec_vnd: float,
        price_at_review_vnd: float,
        return_pct: float,
        benchmark_return_pct: float,
        excess_return_pct: float,
        completed_at: datetime | None = None,
    ) -> None:
        """Record a numerically-evaluated outcome (HIT/MISS/PARTIAL/INCONCLUSIVE)."""
        if status == OutcomeStatus.PENDING:
            raise InvariantViolation(
                "mark_evaluated requires a non-PENDING status; "
                "use mark_invalid for conditional INVALID"
            )
        if not self.is_pending():
            raise InvariantViolation(
                f"OutcomeReview {self.review_id} is already {self.status}; "
                "evaluation is terminal"
            )
        self.status = status
        self.price_at_rec_vnd = price_at_rec_vnd
        self.price_at_review_vnd = price_at_review_vnd
        self.return_pct = return_pct
        self.benchmark_return_pct = benchmark_return_pct
        self.excess_return_pct = excess_return_pct
        self.completed_at = completed_at if completed_at is not None else datetime.now(UTC)

    def mark_invalid(self, *, reason: str, completed_at: datetime | None = None) -> None:
        """BR-7 path — a conditional recommendation whose condition never met."""
        if not self.is_pending():
            raise InvariantViolation(
                f"OutcomeReview {self.review_id} is already {self.status}; "
                "cannot mark INVALID"
            )
        self.status = OutcomeStatus.INVALID
        self.notes = reason
        self.completed_at = completed_at if completed_at is not None else datetime.now(UTC)
