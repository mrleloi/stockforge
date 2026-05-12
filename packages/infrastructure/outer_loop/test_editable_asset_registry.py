"""EditableAssetRegistry — JSON-backed catalog tests."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from packages.domain.outer_loop.value_objects.asset_safety import AssetSafety
from packages.infrastructure.outer_loop.editable_asset_registry import (
    EditableAssetRegistry,
    RegistryFormatError,
)


def _sample_payload() -> dict:
    return {
        "editable_assets": [
            {
                "id": "confluence_weights",
                "path": "configs/signals/confluence-weights.yaml",
                "description": "tier shares",
                "mutation_types": ["numeric_range", "numeric_relative"],
                "safety": "high",
            },
            {
                "id": "screening_rules",
                "path": "configs/screeners/*.yaml",
                "description": "screening variants",
                "mutation_types": ["rule_addition"],
                "safety": "low",
            },
            {
                "id": "synthesizer_prompt",
                "path": "prompts/analysis/synthesizer.md",
                "description": "synthesizer prompt",
                "mutation_types": ["prompt_variant"],
                "safety": "high",
                "human_review_required": "line_by_line",
            },
        ]
    }


def test_load_from_dict_parses_all_fields() -> None:
    reg = EditableAssetRegistry.from_dict(_sample_payload())
    assert len(reg) == 3
    assert "confluence_weights" in reg
    assert reg.get("synthesizer_prompt").requires_line_review()


def test_iter_by_safety_filters_correctly() -> None:
    reg = EditableAssetRegistry.from_dict(_sample_payload())
    high = list(reg.iter_by_safety(AssetSafety.HIGH))
    low = list(reg.iter_by_safety(AssetSafety.LOW))
    assert {a.asset_id for a in high} == {"confluence_weights", "synthesizer_prompt"}
    assert {a.asset_id for a in low} == {"screening_rules"}


def test_load_from_path_round_trip(tmp_path: Path) -> None:
    target = tmp_path / "registry.json"
    target.write_text(json.dumps(_sample_payload()), encoding="utf-8")
    reg = EditableAssetRegistry.load_from_path(target)
    assert len(reg) == 3


def test_rejects_duplicate_asset_id() -> None:
    payload = {
        "editable_assets": [
            {"id": "x", "path": "x", "description": "x", "mutation_types": ["a"], "safety": "low"},
            {"id": "x", "path": "x", "description": "x", "mutation_types": ["a"], "safety": "low"},
        ]
    }
    with pytest.raises(RegistryFormatError, match="duplicate"):
        EditableAssetRegistry.from_dict(payload)


def test_rejects_unknown_safety_level() -> None:
    payload = {
        "editable_assets": [
            {
                "id": "x",
                "path": "x",
                "description": "x",
                "mutation_types": ["a"],
                "safety": "extreme",
            }
        ]
    }
    with pytest.raises(RegistryFormatError, match="safety"):
        EditableAssetRegistry.from_dict(payload)


def test_rejects_missing_required_field() -> None:
    payload = {"editable_assets": [{"id": "x", "path": "x", "safety": "low"}]}
    with pytest.raises(RegistryFormatError, match="missing"):
        EditableAssetRegistry.from_dict(payload)


def test_load_from_path_raises_for_missing_file(tmp_path: Path) -> None:
    with pytest.raises(RegistryFormatError, match="does not exist"):
        EditableAssetRegistry.load_from_path(tmp_path / "absent.json")
