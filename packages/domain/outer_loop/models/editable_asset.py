"""EditableAsset — pipeline parameter / prompt / rule that the outer loop may mutate.

Per spec 005 § B.1: each editable asset declares id + path + description +
mutation_types + safety. Phase 3 stores the registry; Year 2 reads it to pick
candidates for weekly optimization runs (UC-1).

Invariants:
- asset_id non-empty
- path non-empty
- mutation_types non-empty (at least one mutation strategy declared)
- when safety=HIGH and human_review_required is None, document why (e.g.
  numeric_range with bounded delta is acceptable HIGH-safety without line review).
"""

from __future__ import annotations

from dataclasses import dataclass, field

from packages.domain.outer_loop.value_objects.asset_safety import AssetSafety

__all__ = ["EditableAsset", "InvariantViolation"]


class InvariantViolation(ValueError):
    """Raised when EditableAsset construction violates a domain invariant."""


@dataclass(frozen=True, slots=True)
class EditableAsset:
    asset_id: str
    path: str
    description: str
    mutation_types: tuple[str, ...]
    safety: AssetSafety
    human_review_required: str | None = None
    extras: dict[str, str] = field(default_factory=dict)

    def __post_init__(self) -> None:
        if not self.asset_id.strip():
            raise InvariantViolation("asset_id must be non-empty")
        if not self.path.strip():
            raise InvariantViolation(f"path must be non-empty (asset_id={self.asset_id})")
        if not self.mutation_types:
            raise InvariantViolation(
                f"mutation_types must declare ≥1 strategy (asset_id={self.asset_id})"
            )
        for mt in self.mutation_types:
            if not mt.strip():
                raise InvariantViolation(
                    f"mutation_types entries must be non-empty (asset_id={self.asset_id})"
                )

    def requires_line_review(self) -> bool:
        return self.human_review_required == "line_by_line"
