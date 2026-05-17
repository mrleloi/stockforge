"""Unit tests for PersonaRegistry (plan-034 D4).

Covers:
  TC-reg-1:  register and get — happy path
  TC-reg-2:  register duplicate role_id raises PersonaRegistryError
  TC-reg-3:  get unregistered role_id raises KeyError with informative message
  TC-reg-4:  all_role_ids returns sorted tuple (determinism)
  TC-reg-5:  load_from_json happy path — writes JSON; loads; verifies pack registered
  TC-reg-6:  load_from_json rejects '..' traversal segments
  TC-reg-7:  load_from_json rejects symlinks (skipped on Windows if permission denied)
  TC-reg-8:  load_from_json rejects path outside base_dir
  TC-reg-9:  load_from_json malformed JSON raises PersonaRegistryError
  TC-reg-10: load_from_json rejects non-.json extension

All tests: pure unit; no network; no subprocess.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

import pytest

from packages.application.analysis.persona_registry import PersonaRegistry, PersonaRegistryError
from packages.application.analysis.role_prompt_pack import RolePromptPack

# ---------------------------------------------------------------------------
# Shared fixture helpers
# ---------------------------------------------------------------------------

_VALID_PACK_KWARGS: dict[str, object] = {
    "role_id": "buffett",
    "persona_name": "Warren Buffett (value + quality + moat)",
    "system_prompt_template": "You are analyzing {TICKER} as a value investor.",
    "conviction_guidance": "STRONG = moat >= 3 categories; MODERATE = mixed.",
    "citation_requirements": "Every claim cites source_url + source_excerpt ≤500 chars.",
    "vietnam_notes": "VHM is VinGroup-affiliated.",
    "min_points": 3,
    "min_distinct_categories": 3,
    "category_universe": ("MOAT", "MANAGEMENT", "VALUATION", "ROIC", "BALANCE_SHEET", "GROWTH"),
    "model_id_preference": None,
}

_VALID_PACK_KWARGS_2: dict[str, object] = {
    **_VALID_PACK_KWARGS,
    "role_id": "graham",
    "persona_name": "Benjamin Graham (margin of safety)",
}

_VALID_PACK_KWARGS_3: dict[str, object] = {
    **_VALID_PACK_KWARGS,
    "role_id": "taleb",
    "persona_name": "Nassim Taleb (tail risk + fragility)",
}


def _make_pack(**overrides: object) -> RolePromptPack:
    kwargs = dict(_VALID_PACK_KWARGS)
    kwargs.update(overrides)
    return RolePromptPack(**kwargs)  # type: ignore[arg-type]


def _write_json(path: Path, data: dict[str, object]) -> None:
    path.write_text(json.dumps(data), encoding="utf-8")


# ---------------------------------------------------------------------------
# TC-reg-1: register and get
# ---------------------------------------------------------------------------


def test_register_and_get_returns_same_instance() -> None:
    """TC-reg-1: register pack; lookup returns same instance."""
    reg = PersonaRegistry()
    pack = _make_pack()
    reg.register(pack)
    assert reg.get("buffett") is pack


# ---------------------------------------------------------------------------
# TC-reg-2: register duplicate role_id raises
# ---------------------------------------------------------------------------


def test_register_duplicate_role_id_raises() -> None:
    """TC-reg-2: Registering 2nd pack with same role_id raises PersonaRegistryError."""
    reg = PersonaRegistry()
    pack1 = _make_pack()
    pack2 = _make_pack(persona_name="Different name")
    reg.register(pack1)
    with pytest.raises(PersonaRegistryError, match="already registered"):
        reg.register(pack2)


# ---------------------------------------------------------------------------
# TC-reg-3: get unregistered raises KeyError
# ---------------------------------------------------------------------------


def test_get_unregistered_raises_keyerror() -> None:
    """TC-reg-3: KeyError with informative message listing registered role_ids."""
    reg = PersonaRegistry()
    reg.register(_make_pack())
    with pytest.raises(KeyError, match="not registered"):
        reg.get("taleb")


def test_get_unregistered_lists_registered_in_error() -> None:
    """TC-reg-3b: KeyError message includes list of registered ids."""
    reg = PersonaRegistry()
    reg.register(_make_pack())
    try:
        reg.get("unknown")
    except KeyError as exc:
        assert "buffett" in str(exc)


# ---------------------------------------------------------------------------
# TC-reg-4: all_role_ids returns sorted tuple
# ---------------------------------------------------------------------------


def test_all_role_ids_returns_sorted_tuple() -> None:
    """TC-reg-4: Register 3 packs in shuffled order; all_role_ids returns sorted."""
    reg = PersonaRegistry()
    # Register in non-alphabetical order
    reg.register(RolePromptPack(**_VALID_PACK_KWARGS_3))  # type: ignore[arg-type]
    reg.register(RolePromptPack(**_VALID_PACK_KWARGS))    # type: ignore[arg-type]
    reg.register(RolePromptPack(**_VALID_PACK_KWARGS_2))  # type: ignore[arg-type]
    ids = reg.all_role_ids()
    assert isinstance(ids, tuple)
    assert ids == ("buffett", "graham", "taleb")


def test_all_role_ids_empty_registry() -> None:
    """TC-reg-4b: Empty registry returns empty tuple."""
    reg = PersonaRegistry()
    assert reg.all_role_ids() == ()


# ---------------------------------------------------------------------------
# TC-reg-5: load_from_json happy path
# ---------------------------------------------------------------------------


def test_load_from_json_happy_path(tmp_path: Path) -> None:
    """TC-reg-5: Write JSON file; load; verify pack registered with correct fields."""
    json_data: dict[str, object] = {
        "role_id": "graham",
        "persona_name": "Benjamin Graham (margin of safety)",
        "system_prompt_template": "Analyze {TICKER} with margin of safety.",
        "conviction_guidance": "STRONG = PE < 15 and PB < 1.5.",
        "citation_requirements": "Every claim cites source_url.",
        "vietnam_notes": "",
        "min_points": 3,
        "min_distinct_categories": 2,
        "category_universe": ["VALUATION", "BALANCE_SHEET", "EARNINGS"],
        "model_id_preference": None,
    }
    json_file = tmp_path / "graham.json"
    _write_json(json_file, json_data)

    reg = PersonaRegistry()
    reg.load_from_json(json_file)

    pack = reg.get("graham")
    assert pack.role_id == "graham"
    assert pack.category_universe == ("VALUATION", "BALANCE_SHEET", "EARNINGS")
    assert isinstance(pack.category_universe, tuple)
    assert pack.min_distinct_categories == 2


# ---------------------------------------------------------------------------
# TC-reg-6: load_from_json rejects '..' traversal
# ---------------------------------------------------------------------------


def test_load_from_json_rejects_traversal_segments() -> None:
    """TC-reg-6: Path with '..' segments raises PersonaRegistryError."""
    reg = PersonaRegistry()
    bad_path = Path("role-packs/../../../etc/passwd.json")
    with pytest.raises(PersonaRegistryError, match=r"'\.\.'"):
        reg.load_from_json(bad_path)


# ---------------------------------------------------------------------------
# TC-reg-7: load_from_json rejects symlinks
# ---------------------------------------------------------------------------


@pytest.mark.skipif(
    sys.platform == "win32" and not os.environ.get("STOCKFORGE_ENABLE_SYMLINK_TESTS"),
    reason="Symlink creation requires elevated permissions on Windows; "
           "set STOCKFORGE_ENABLE_SYMLINK_TESTS=1 to run",
)
def test_load_from_json_rejects_symlink(tmp_path: Path) -> None:
    """TC-reg-7: Symlink to JSON file raises PersonaRegistryError (D-064)."""
    real_file = tmp_path / "real.json"
    _write_json(real_file, {
        "role_id": "test",
        "persona_name": "Test",
        "system_prompt_template": "Analyze {TICKER}.",
        "conviction_guidance": "guide",
        "citation_requirements": "cite",
        "vietnam_notes": "",
        "min_points": 1,
        "min_distinct_categories": 1,
        "category_universe": ["CAT"],
        "model_id_preference": None,
    })
    symlink = tmp_path / "link.json"
    symlink.symlink_to(real_file)

    reg = PersonaRegistry()
    with pytest.raises(PersonaRegistryError, match="symlink"):
        reg.load_from_json(symlink)


# ---------------------------------------------------------------------------
# TC-reg-8: load_from_json rejects path outside base_dir
# ---------------------------------------------------------------------------


def test_load_from_json_rejects_outside_base_dir(tmp_path: Path) -> None:
    """TC-reg-8: Path outside base_dir raises PersonaRegistryError."""
    other_dir = tmp_path / "other"
    other_dir.mkdir()
    json_file = other_dir / "pack.json"
    _write_json(json_file, {
        "role_id": "graham",
        "persona_name": "Graham",
        "system_prompt_template": "Analyze {TICKER}.",
        "conviction_guidance": "guide",
        "citation_requirements": "cite",
        "vietnam_notes": "",
        "min_points": 1,
        "min_distinct_categories": 1,
        "category_universe": ["CAT"],
        "model_id_preference": None,
    })
    base = tmp_path / "allowed"
    base.mkdir()

    reg = PersonaRegistry()
    with pytest.raises(PersonaRegistryError, match="outside base_dir"):
        reg.load_from_json(json_file, base_dir=base)


# ---------------------------------------------------------------------------
# TC-reg-9: load_from_json malformed JSON raises
# ---------------------------------------------------------------------------


def test_load_from_json_malformed_json_raises(tmp_path: Path) -> None:
    """TC-reg-9: Invalid JSON syntax raises PersonaRegistryError wrapping JSONDecodeError."""
    bad_file = tmp_path / "bad.json"
    bad_file.write_text("{not valid json {{{{", encoding="utf-8")

    reg = PersonaRegistry()
    with pytest.raises(PersonaRegistryError, match="failed to read/parse"):
        reg.load_from_json(bad_file)


# ---------------------------------------------------------------------------
# TC-reg-10: load_from_json rejects non-.json extension
# ---------------------------------------------------------------------------


def test_load_from_json_rejects_yaml_extension(tmp_path: Path) -> None:
    """TC-reg-10: .yaml extension raises PersonaRegistryError."""
    yaml_file = tmp_path / "pack.yaml"
    yaml_file.write_text("role_id: test\n", encoding="utf-8")

    reg = PersonaRegistry()
    with pytest.raises(PersonaRegistryError, match=".json"):
        reg.load_from_json(yaml_file)


def test_load_from_json_rejects_txt_extension(tmp_path: Path) -> None:
    """TC-reg-10b: .txt extension raises PersonaRegistryError."""
    txt_file = tmp_path / "pack.txt"
    txt_file.write_text("{}", encoding="utf-8")

    reg = PersonaRegistry()
    with pytest.raises(PersonaRegistryError, match=".json"):
        reg.load_from_json(txt_file)
