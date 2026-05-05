"""Recommendation heuristic — pure deterministic logic (Phase 1, BR-7).

NO LLM. Maps Synthesis → Recommendation + ConfidenceLevel using a decision
table per spec 001 § B.3 and spec 006 § A.6.1.

Decision table (precedence order):
1. Any disagreement detected → INVESTIGATE (always, per BR-3 / I-S12).
   Disagreement = conflicting Bear/Bull conclusions; never collapse to HOLD.
2. STRONG_CONSENSUS + all STRONG dimension verdicts → THESIS_CANDIDATE (HIGH)
3. STRONG_CONSENSUS + mixed verdicts → WATCH (MEDIUM)
4. MIXED confluence → WATCH (MEDIUM) or INVESTIGATE (LOW) based on evidence quality
5. Any other → PASS (LOW)

ConfidenceLevel mapping:
- THESIS_CANDIDATE → HIGH
- WATCH → MEDIUM
- INVESTIGATE → LOW (disagreement or insufficient evidence)
- PASS → LOW

This heuristic is Phase 1 only. Phase 4 replaces with calibration-backed logic.
Documented per BR-7: "Phase-1-Compatible Confidence".

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § A.6.1.
"""

from __future__ import annotations

from packages.domain.analysis.models.synthesis import Confluence, Synthesis
from packages.domain.analysis.value_objects.confidence_level import ConfidenceLevel
from packages.domain.analysis.value_objects.recommendation import Recommendation
from packages.domain.analysis.value_objects.trade_off_matrix import DimensionVerdict

__all__ = ["confidence_from_synthesis", "recommendation_from_synthesis"]


def recommendation_from_synthesis(synthesis: Synthesis) -> Recommendation:
    """Map a Synthesis to a Recommendation using Phase 1 heuristic (BR-7).

    Disagreement always yields INVESTIGATE per I-S12 — never vote-average.
    """
    # Rule 1: disagreement overrides everything → INVESTIGATE
    if synthesis.explicit_disagreements:
        return Recommendation.INVESTIGATE

    confluence = synthesis.confluence_assessment
    scores = synthesis.trade_off_matrix.scores

    if confluence == Confluence.STRONG_CONSENSUS:
        # All dimensions STRONG → thesis candidate
        if scores and all(v == DimensionVerdict.STRONG for v in scores.values()):
            return Recommendation.THESIS_CANDIDATE
        # Any dimension WEAK in supposed consensus → WATCH
        if any(v == DimensionVerdict.WEAK for v in scores.values()):
            return Recommendation.WATCH
        return Recommendation.WATCH

    if confluence == Confluence.MIXED:
        # Mixed with some STRONG evidence → still worth investigating
        has_strong = any(v == DimensionVerdict.STRONG for v in scores.values())
        if has_strong:
            return Recommendation.WATCH
        return Recommendation.INVESTIGATE

    # DISAGREEMENT confluence without explicit_disagreements = synthesizer bug;
    # safe fallback: INVESTIGATE
    if confluence == Confluence.DISAGREEMENT:
        return Recommendation.INVESTIGATE

    return Recommendation.PASS


def confidence_from_synthesis(synthesis: Synthesis) -> ConfidenceLevel:
    """Map a Synthesis to a ConfidenceLevel using Phase 1 heuristic (BR-7).

    Phase 2 has calibration_grade D (no historical hit rate). This heuristic
    is intentionally conservative.
    """
    rec = recommendation_from_synthesis(synthesis)

    if rec == Recommendation.THESIS_CANDIDATE:
        return ConfidenceLevel.HIGH
    if rec == Recommendation.WATCH:
        return ConfidenceLevel.MEDIUM
    # INVESTIGATE or PASS → LOW
    return ConfidenceLevel.LOW
