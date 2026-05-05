"""Thesis — BC-8 Analysis aggregate root.

Thesis is the top-level immutable entity that encapsulates a complete
multi-perspective stock analysis. It enforces:
- BR-1 / I-S10: bear case ≥3 distinct points + ≥3 distinct categories (on SUBMITTED)
- BR-3 / I-S12: disagreement preserved (delegated to Synthesis.__post_init__)
- AC-5 reproducibility: thesis_id is sha256(model_id + prompt_hash + ticker + as_of + data_md5)

ThesisStatus:
- DRAFT: intermediate; not persisted to repository
- SUBMITTED: fully validated; aggregate invariants enforced
- INCOMPLETE: data gaps prevented full analysis; synthesis=None

Thesis.incomplete() classmethod creates an INCOMPLETE Thesis with
synthesis=None, final_recommendation=None, confidence_level=None, cost_usd=0.

BearCaseInvariantError is raised at __post_init__ when status=SUBMITTED
and the bear case fails ≥3 distinct points + ≥3 distinct categories.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.2.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal
from enum import StrEnum

from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.models.synthesis import Synthesis
from packages.domain.analysis.value_objects.confidence_level import ConfidenceLevel
from packages.domain.analysis.value_objects.recommendation import Recommendation

__all__ = ["BearCaseInvariantError", "Thesis", "ThesisStatus"]


class BearCaseInvariantError(ValueError):
    """Raised when Thesis.submit() validates a bear case that is insufficient.

    Cases that raise:
    - Fewer than 3 key_points in the bear perspective
    - Fewer than 3 distinct categories across bear key_points
    - Bear perspective not present in perspectives tuple
    """


class ThesisStatus(StrEnum):
    """Lifecycle state of a Thesis aggregate."""

    DRAFT = "draft"
    SUBMITTED = "submitted"
    INCOMPLETE = "incomplete"


@dataclass(frozen=True, slots=True)
class Thesis:
    """Immutable thesis aggregate root.

    Enforces bear-case invariants on SUBMITTED status. INCOMPLETE theses
    carry no synthesis, recommendation, or confidence — they record data gaps.

    `thesis_id`: deterministic sha256 hash for reproducibility (AC-5).
    `calibration_grade`: always "D" in Phase 2 (no calibration data yet, BR-7).
    `n_samples`: 0 in Phase 2; Phase 3+ backfills from post-mortems.
    `gaps`: list of gap labels when status=INCOMPLETE (e.g. "price_stale").
    """

    thesis_id: str
    ticker: Ticker
    as_of: date
    created_at: datetime
    status: ThesisStatus
    perspectives: tuple[PerspectiveAnalysis, ...]
    synthesis: Synthesis | None
    final_recommendation: Recommendation | None
    confidence_level: ConfidenceLevel | None
    cost_usd: Decimal
    calibration_grade: str = "D"
    n_samples: int = 0
    gaps: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        if self.status == ThesisStatus.SUBMITTED:
            self._enforce_bear_case()

    def _enforce_bear_case(self) -> None:
        """BR-1 / I-S10: SUBMITTED thesis must have ≥3 distinct bear points
        across ≥3 distinct categories.
        """
        bear = next(
            (p for p in self.perspectives if p.role == PerspectiveRole.BEAR),
            None,
        )
        if bear is None:
            raise BearCaseInvariantError(
                "No BEAR perspective found in thesis (I-S10): "
                "SUBMITTED thesis requires a bear perspective."
            )
        if len(bear.key_points) < 3:
            raise BearCaseInvariantError(
                f"Bear case has only {len(bear.key_points)} point(s); "
                "≥3 distinct bear points required (I-S10 / BR-1)."
            )
        cats = {p.category for p in bear.key_points if p.category}
        if len(cats) < 3:
            raise BearCaseInvariantError(
                f"Bear case has only {len(cats)} distinct category(ies) "
                f"({sorted(cats)}); ≥3 distinct categories required (I-S10 / BR-1). "
                "Three rephrasings of the same risk do not constitute a bear case."
            )

    @classmethod
    def incomplete(
        cls,
        ticker: Ticker,
        as_of: date,
        gaps: list[str],
        *,
        created_at: datetime | None = None,
    ) -> Thesis:
        """Return an INCOMPLETE Thesis recording data gaps that prevented analysis.

        Used by ValidateThesisPhase1UseCase when SharedContext.has_critical_gaps()
        returns True or BearCaseInvariantError is raised after retry.
        cost_usd=Decimal("0") because no LLM calls were billed to a complete analysis.
        """
        from datetime import UTC

        return cls(
            thesis_id="incomplete",
            ticker=ticker,
            as_of=as_of,
            created_at=created_at or datetime.now(UTC),
            status=ThesisStatus.INCOMPLETE,
            perspectives=(),
            synthesis=None,
            final_recommendation=None,
            confidence_level=None,
            cost_usd=Decimal("0"),
            gaps=tuple(gaps),
        )
