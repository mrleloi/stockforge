"""GroundedPoint — a single cited analytical claim.

Every claim in a thesis perspective must carry:
- source_url: non-empty (I-1 mandatory provenance)
- source_excerpt: verbatim quote ≤500 chars (Rule 6 inherits from BC-5 ExtractedClaim)
- as_of: non-null date (I-S2 point-in-time)
- conviction: STRONG | MODERATE | WEAK
- category: optional BearCategory for bear points; None for bull/quant points

Post-init enforces all three hard invariants — no GroundedPoint can exist
without grounding. This is the first line of defence against hallucinated
source_urls per A.7 risk mitigation.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.2 + § A.11.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date

from packages.domain.analysis.value_objects.conviction import Conviction

__all__ = ["GroundedPoint", "GroundedPointInvariantError"]

_MAX_EXCERPT_CHARS = 500


class GroundedPointInvariantError(ValueError):
    """Raised when a GroundedPoint violates I-1 or Rule 6 invariants."""


@dataclass(frozen=True, slots=True)
class GroundedPoint:
    """Immutable cited analytical claim. Frozen + slotted — no mutation post-emit.

    `text` is the claim itself.
    `source_url` must be non-empty (I-1).
    `source_excerpt` must be non-empty and ≤500 chars verbatim (Rule 6).
    `as_of` is the point-in-time the claim was sourced (I-S2).
    `conviction` is the analyst's strength of belief.
    `category` is the BearCategory enum value or raw str (None for non-bear points).
    `key_phrases` aids Jaccard-overlap distinctness check (§ A.11 rule 3).
    """

    text: str
    source_url: str
    source_excerpt: str
    as_of: date
    conviction: Conviction
    category: str | None = None
    key_phrases: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        if not self.source_url.strip():
            raise GroundedPointInvariantError(
                "source_url required (I-1): every claim must cite its source"
            )
        if not self.source_excerpt.strip():
            raise GroundedPointInvariantError(
                "source_excerpt required (Rule 6): verbatim quote grounding the claim"
            )
        if len(self.source_excerpt) > _MAX_EXCERPT_CHARS:
            raise GroundedPointInvariantError(
                f"source_excerpt exceeds {_MAX_EXCERPT_CHARS} chars "
                f"(got {len(self.source_excerpt)}); Rule 6 verbatim excerpt limit"
            )
        if not self.text.strip():
            raise GroundedPointInvariantError(
                "text required: the claim body must not be empty"
            )
