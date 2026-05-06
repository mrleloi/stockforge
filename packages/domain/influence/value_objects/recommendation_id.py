"""RecommendationId — stable identity value object for a Recommendation.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1.
"""

from __future__ import annotations

from dataclasses import dataclass

__all__ = ["RecommendationId"]


@dataclass(frozen=True, slots=True)
class RecommendationId:
    """Stable, opaque identifier for an extracted Recommendation."""

    value: str

    def __post_init__(self) -> None:
        if not self.value or not self.value.strip():
            raise ValueError("RecommendationId.value must be a non-empty string")

    def __str__(self) -> str:
        return self.value
