"""OutcomeReviewCompleted — BC-6 emits when an OutcomeReview reaches terminal status.

Cross-BC contract event. Per spec § B.2. Subscribers may react by:
- Triggering UC-3 credibility recompute (BC-6 internal subscriber when
  review_window == THREE_MONTH).
- Logging the (HIT, MISS, PARTIAL, INVALID, INCONCLUSIVE) outcome to
  calibration history.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

__all__ = ["OutcomeReviewCompleted"]


@dataclass(frozen=True, slots=True)
class OutcomeReviewCompleted:
    """Event emitted by EvaluateOutcomeReviewUseCase on terminal outcome."""

    review_id: str
    recommendation_id: str
    review_window: str
    status: str
    excess_return_pct: float | None
    completed_at: datetime
