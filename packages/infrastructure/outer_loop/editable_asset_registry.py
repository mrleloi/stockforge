"""EditableAssetRegistry — JSON-backed catalog of mutable pipeline assets.

Phase 3 Track L deliverable per master-plan §S55. Year 2 weekly_runner.UC-1
reads this registry to pick a candidate asset per optimization cycle.

Format (JSON; YAML deferred to Year 2 to avoid PyYAML dependency drift):
```json
{
  "editable_assets": [
    {
      "id": "confluence_weights",
      "path": "configs/signals/confluence-weights.yaml",
      "description": "How much each tier contributes to confluence score",
      "mutation_types": ["numeric_range", "numeric_relative"],
      "safety": "high",
      "human_review_required": "line_by_line"  // optional
    }
  ]
}
```

Source: specs/tier2-feature/005-karpathy-outer-loop.md § B.1.
"""

from __future__ import annotations

import json
from collections.abc import Iterable
from pathlib import Path

from packages.domain.outer_loop.models.editable_asset import (
    EditableAsset,
    InvariantViolation,
)
from packages.domain.outer_loop.value_objects.asset_safety import AssetSafety

__all__ = ["EditableAssetRegistry", "RegistryFormatError"]


class RegistryFormatError(ValueError):
    """Raised when the registry JSON has wrong shape or invalid asset entries."""


class EditableAssetRegistry:
    """In-memory catalog of EditableAsset entries loaded from JSON config."""

    def __init__(self, assets: list[EditableAsset]):
        self._by_id: dict[str, EditableAsset] = {}
        for a in assets:
            if a.asset_id in self._by_id:
                raise RegistryFormatError(
                    f"duplicate asset_id {a.asset_id!r} in registry"
                )
            self._by_id[a.asset_id] = a

    @classmethod
    def load_from_path(cls, path: Path | str) -> EditableAssetRegistry:
        p = Path(path)
        if not p.exists():
            raise RegistryFormatError(f"registry path does not exist: {p}")
        try:
            payload = json.loads(p.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise RegistryFormatError(f"registry JSON malformed at {p}: {exc}") from exc
        return cls.from_dict(payload)

    @classmethod
    def from_dict(cls, payload: dict[str, object]) -> EditableAssetRegistry:
        if not isinstance(payload, dict) or "editable_assets" not in payload:
            raise RegistryFormatError(
                "registry payload must be {'editable_assets': [...]}"
            )
        raw_list = payload["editable_assets"]
        if not isinstance(raw_list, list):
            raise RegistryFormatError("'editable_assets' must be a list")
        assets: list[EditableAsset] = []
        for idx, raw in enumerate(raw_list):
            if not isinstance(raw, dict):
                raise RegistryFormatError(
                    f"editable_assets[{idx}] must be an object, got {type(raw).__name__}"
                )
            assets.append(cls._parse_one(idx, raw))
        return cls(assets)

    @staticmethod
    def _parse_one(idx: int, raw: dict[str, object]) -> EditableAsset:
        for required_field in ("id", "path", "description", "mutation_types", "safety"):
            if required_field not in raw:
                raise RegistryFormatError(
                    f"editable_assets[{idx}] missing required field {required_field!r}"
                )
        mutation_types_raw = raw["mutation_types"]
        if not isinstance(mutation_types_raw, list) or not all(
            isinstance(m, str) for m in mutation_types_raw
        ):
            raise RegistryFormatError(
                f"editable_assets[{idx}].mutation_types must be list[str]"
            )
        safety_raw = raw["safety"]
        if not isinstance(safety_raw, str):
            raise RegistryFormatError(
                f"editable_assets[{idx}].safety must be string"
            )
        try:
            safety = AssetSafety(safety_raw)
        except ValueError as exc:
            raise RegistryFormatError(
                f"editable_assets[{idx}].safety={safety_raw!r} not in "
                f"{[s.value for s in AssetSafety]}"
            ) from exc
        human_review = raw.get("human_review_required")
        if human_review is not None and not isinstance(human_review, str):
            raise RegistryFormatError(
                f"editable_assets[{idx}].human_review_required must be string or null"
            )
        try:
            return EditableAsset(
                asset_id=str(raw["id"]),
                path=str(raw["path"]),
                description=str(raw["description"]),
                mutation_types=tuple(mutation_types_raw),
                safety=safety,
                human_review_required=human_review,
            )
        except InvariantViolation as exc:
            raise RegistryFormatError(
                f"editable_assets[{idx}] invariant violation: {exc}"
            ) from exc

    def get(self, asset_id: str) -> EditableAsset | None:
        return self._by_id.get(asset_id)

    def all(self) -> list[EditableAsset]:
        return list(self._by_id.values())

    def iter_by_safety(self, safety: AssetSafety) -> Iterable[EditableAsset]:
        for a in self._by_id.values():
            if a.safety == safety:
                yield a

    def __len__(self) -> int:
        return len(self._by_id)

    def __contains__(self, asset_id: object) -> bool:
        return isinstance(asset_id, str) and asset_id in self._by_id
