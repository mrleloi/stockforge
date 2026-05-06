"""KolId — stable identity value object for a KOL entity.

Wraps a non-empty string identifier. Construction raises ValueError on
empty/whitespace input so invalid states are unrepresentable.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1.
"""

from __future__ import annotations

from dataclasses import dataclass

__all__ = ["KolId"]


@dataclass(frozen=True, slots=True)
class KolId:
    """Stable, opaque identifier for a KOL.

    Typically a UUID4 string generated at KOL creation.
    """

    value: str

    def __post_init__(self) -> None:
        if not self.value or not self.value.strip():
            raise ValueError("KolId.value must be a non-empty string")

    def __str__(self) -> str:
        return self.value
