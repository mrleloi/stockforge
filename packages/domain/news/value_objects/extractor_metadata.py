"""ExtractorMetadata — provenance bundle per financial-data-protocol Rule 6.

Every LLM-extracted claim must carry these fields so we can answer "was this
real or hallucinated?" months later. Without all fields the claim cannot be
inserted into a repository (Rule 6 enforcement).

Source: agent-workspace/constitution/financial-data-protocol.md Rule 6;
agent-workspace/constitution/invariants.md I-S1 + I-1.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

__all__ = ["ExtractorMetadata", "ExtractorMetadataInvariantError"]


class ExtractorMetadataInvariantError(ValueError):
    """Raised when an ExtractorMetadata is constructed with values violating
    Rule 6 (LLM Output Provenance).
    """


@dataclass(frozen=True, slots=True)
class ExtractorMetadata:
    """Provenance bundle attached to every ExtractedClaim. Frozen + slotted so
    a single record cannot be mutated post-emit (Rule 6 audit trail).

    Fields per Rule 6:
    - extractor_model: e.g. "claude-sonnet-4-6" (model name + version)
    - extractor_version: code version (commit SHA short-form acceptable)
    - extractor_prompt_hash: SHA-256 of the system prompt used (reproducibility)
    - extracted_at: wall-clock when extraction completed
    - confidence_extracted: LLM-stated confidence in [0, 1]
    - verified_by_human: default False; flipped True only by reviewer agent
    """

    extractor_model: str
    extractor_version: str
    extractor_prompt_hash: str
    extracted_at: datetime
    confidence_extracted: float
    verified_by_human: bool = False

    def __post_init__(self) -> None:
        if not self.extractor_model.strip():
            raise ExtractorMetadataInvariantError(
                "extractor_model is required (Rule 6)"
            )
        if not self.extractor_version.strip():
            raise ExtractorMetadataInvariantError(
                "extractor_version is required (Rule 6)"
            )
        if not self.extractor_prompt_hash.strip():
            raise ExtractorMetadataInvariantError(
                "extractor_prompt_hash is required (Rule 6 — reproducibility)"
            )
        if not 0.0 <= self.confidence_extracted <= 1.0:
            raise ExtractorMetadataInvariantError(
                f"confidence_extracted {self.confidence_extracted} outside [0, 1] (Rule 6)"
            )
