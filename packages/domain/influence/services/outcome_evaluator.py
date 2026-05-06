"""OutcomeEvaluator — deterministic HIT/MISS/PARTIAL/INCONCLUSIVE classifier (UC-2).

Pure function: maps (intent, excess_return, timeframe) → OutcomeStatus.

Threshold matrix per spec § B.3 UC-2:
- DAYS:      ±3%
- WEEKS:     ±5%
- MONTHS:   ±10%
- LONG_TERM:±15%

INTRADAY uses the DAYS threshold (spec leaves intraday under daily horizon).

Rules:
- STRONG_BUY / BUY:
    excess_return >= threshold     → HIT
    excess_return >= threshold/2   → PARTIAL
    otherwise                      → MISS
- STRONG_AVOID / AVOID:
    excess_return <= -threshold    → HIT (right to avoid)
    excess_return <= -threshold/2  → PARTIAL
    otherwise                      → MISS
- NEUTRAL:
    abs(excess_return) <= threshold/2 → HIT (neutral confirmed)
    otherwise                          → MISS
- WATCH:                              → INCONCLUSIVE (informational)

Conditional recommendations (BR-7) are NOT evaluated here — the use case must
mark them INVALID before calling evaluate() if their condition never met.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.3 UC-2.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § e).
"""

from __future__ import annotations

from packages.domain.influence.models.outcome_review import OutcomeStatus
from packages.domain.influence.value_objects.intent import Intent
from packages.domain.influence.value_objects.timeframe import Timeframe

__all__ = ["EXCESS_RETURN_THRESHOLDS", "OutcomeEvaluator"]


EXCESS_RETURN_THRESHOLDS: dict[Timeframe, float] = {
    Timeframe.INTRADAY: 0.03,
    Timeframe.DAYS: 0.03,
    Timeframe.WEEKS: 0.05,
    Timeframe.MONTHS: 0.10,
    Timeframe.LONG_TERM: 0.15,
}


class OutcomeEvaluator:
    """Stateless evaluator for outcome status given excess return + intent."""

    def evaluate(
        self,
        *,
        intent: Intent,
        timeframe: Timeframe,
        excess_return: float,
    ) -> OutcomeStatus:
        """Classify a recommendation outcome.

        Returns one of HIT / MISS / PARTIAL / INCONCLUSIVE. INVALID is the
        caller's responsibility (BR-7 conditional path).
        """
        threshold = EXCESS_RETURN_THRESHOLDS[timeframe]

        if intent in (Intent.STRONG_BUY, Intent.BUY):
            if excess_return >= threshold:
                return OutcomeStatus.HIT
            if excess_return >= threshold / 2:
                return OutcomeStatus.PARTIAL
            return OutcomeStatus.MISS

        if intent in (Intent.STRONG_AVOID, Intent.AVOID):
            if excess_return <= -threshold:
                return OutcomeStatus.HIT
            if excess_return <= -threshold / 2:
                return OutcomeStatus.PARTIAL
            return OutcomeStatus.MISS

        if intent == Intent.NEUTRAL:
            if abs(excess_return) <= threshold / 2:
                return OutcomeStatus.HIT
            return OutcomeStatus.MISS

        # Intent.WATCH is informational
        return OutcomeStatus.INCONCLUSIVE
