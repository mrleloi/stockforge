"""Unit tests for RolePromptPack frozen dataclass (plan-034 D4).

Covers:
  TC-rpp-1:  valid construction — all 10 fields; instance created
  TC-rpp-2:  role_id validation — empty / uppercase / hyphen-in-id raises
  TC-rpp-3:  system_prompt_template must contain {TICKER} placeholder
  TC-rpp-4:  min_points must be >= 1
  TC-rpp-5:  min_distinct_categories must not exceed category_universe size
  TC-rpp-6:  category_universe must contain unique strings (no duplicates)
  TC-rpp-7:  model_id_preference must be None or one of the 3 allowed models
  TC-rpp-8:  frozen invariant — field assignment after construction raises FrozenInstanceError

All tests: pure unit; no network; no subprocess.
"""

from __future__ import annotations

import dataclasses

import pytest

from packages.application.analysis.role_prompt_pack import (
    RolePromptPack,
    RolePromptPackInvariantError,
)

# ---------------------------------------------------------------------------
# Shared fixture helper
# ---------------------------------------------------------------------------

_VALID_KWARGS: dict[str, object] = {
    "role_id": "buffett",
    "persona_name": "Warren Buffett (value + quality + moat)",
    "system_prompt_template": "You are a value investor analyzing {TICKER} as of {AS_OF}.",
    "conviction_guidance": "STRONG = moat >= 3 categories; MODERATE = mixed; WEAK = single.",
    "citation_requirements": "Every claim cites source_url + source_excerpt ≤500 chars.",
    "vietnam_notes": "VHM is VinGroup-affiliated; consider related-party transaction risk.",
    "min_points": 3,
    "min_distinct_categories": 3,
    "category_universe": ("MOAT", "MANAGEMENT", "VALUATION", "ROIC", "BALANCE_SHEET", "GROWTH"),
    "model_id_preference": None,
}


def _make(**overrides: object) -> RolePromptPack:
    kwargs = dict(_VALID_KWARGS)
    kwargs.update(overrides)
    return RolePromptPack(**kwargs)  # type: ignore[arg-type]


# ---------------------------------------------------------------------------
# TC-rpp-1: Happy path
# ---------------------------------------------------------------------------


def test_valid_construction_all_10_fields() -> None:
    """TC-rpp-1: All 10 fields valid → instance created without error."""
    pack = _make()
    assert pack.role_id == "buffett"
    assert pack.persona_name == "Warren Buffett (value + quality + moat)"
    assert "{TICKER}" in pack.system_prompt_template
    assert pack.min_points == 3
    assert pack.min_distinct_categories == 3
    assert len(pack.category_universe) == 6
    assert pack.model_id_preference is None


def test_valid_construction_with_model_preference() -> None:
    """TC-rpp-1b: model_id_preference set to allowed model → accepted."""
    pack = _make(model_id_preference="claude-sonnet-4-6")
    assert pack.model_id_preference == "claude-sonnet-4-6"


def test_valid_construction_vietnam_notes_empty() -> None:
    """TC-rpp-1c: vietnam_notes may be empty (persona may lack VN-specific notes)."""
    pack = _make(vietnam_notes="")
    assert pack.vietnam_notes == ""


# ---------------------------------------------------------------------------
# TC-rpp-2: role_id validation
# ---------------------------------------------------------------------------


def test_role_id_empty_raises() -> None:
    """TC-rpp-2a: Empty role_id raises RolePromptPackInvariantError."""
    with pytest.raises(RolePromptPackInvariantError, match="role_id"):
        _make(role_id="")


def test_role_id_uppercase_raises() -> None:
    """TC-rpp-2b: Uppercase letters in role_id raise (must be lowercase)."""
    with pytest.raises(RolePromptPackInvariantError, match="role_id"):
        _make(role_id="Buffett")


def test_role_id_hyphen_raises() -> None:
    """TC-rpp-2c: Hyphen in role_id raises (must use underscore)."""
    with pytest.raises(RolePromptPackInvariantError, match="role_id"):
        _make(role_id="buffett-value")


def test_role_id_starts_with_digit_raises() -> None:
    """TC-rpp-2d: role_id starting with digit raises (must start with lowercase letter)."""
    with pytest.raises(RolePromptPackInvariantError, match="role_id"):
        _make(role_id="1buffett")


def test_role_id_underscore_separator_valid() -> None:
    """TC-rpp-2e: Underscore separator is valid (e.g. vn_domain_specialist)."""
    pack = _make(role_id="vn_domain_specialist")
    assert pack.role_id == "vn_domain_specialist"


# ---------------------------------------------------------------------------
# TC-rpp-3: system_prompt_template must contain {TICKER}
# ---------------------------------------------------------------------------


def test_system_prompt_missing_ticker_placeholder_raises() -> None:
    """TC-rpp-3: system_prompt_template without {TICKER} raises."""
    with pytest.raises(RolePromptPackInvariantError, match=r"\{TICKER\}"):
        _make(system_prompt_template="Analyze the company as a value investor.")


def test_system_prompt_with_ticker_valid() -> None:
    """TC-rpp-3b: {TICKER} present → accepted."""
    pack = _make(system_prompt_template="Analyze {TICKER}.")
    assert "{TICKER}" in pack.system_prompt_template


# ---------------------------------------------------------------------------
# TC-rpp-4: min_points >= 1
# ---------------------------------------------------------------------------


def test_min_points_zero_raises() -> None:
    """TC-rpp-4a: min_points=0 raises."""
    with pytest.raises(RolePromptPackInvariantError, match="min_points"):
        _make(min_points=0)


def test_min_points_negative_raises() -> None:
    """TC-rpp-4b: min_points=-1 raises."""
    with pytest.raises(RolePromptPackInvariantError, match="min_points"):
        _make(min_points=-1)


def test_min_points_one_valid() -> None:
    """TC-rpp-4c: min_points=1 is valid floor."""
    pack = _make(min_points=1, min_distinct_categories=1)
    assert pack.min_points == 1


# ---------------------------------------------------------------------------
# TC-rpp-5: min_distinct_categories must not exceed category_universe size
# ---------------------------------------------------------------------------


def test_min_distinct_categories_exceeds_universe_raises() -> None:
    """TC-rpp-5: min_distinct=5 with universe=3 raises."""
    with pytest.raises(RolePromptPackInvariantError, match="exceeds"):
        _make(
            category_universe=("A", "B", "C"),
            min_distinct_categories=5,
        )


def test_min_distinct_categories_equals_universe_valid() -> None:
    """TC-rpp-5b: min_distinct == len(universe) is valid (all categories required)."""
    pack = _make(
        category_universe=("A", "B", "C"),
        min_distinct_categories=3,
        min_points=3,
    )
    assert pack.min_distinct_categories == 3


# ---------------------------------------------------------------------------
# TC-rpp-6: category_universe must have unique strings
# ---------------------------------------------------------------------------


def test_category_universe_duplicates_raise() -> None:
    """TC-rpp-6: Duplicate values in category_universe raise."""
    with pytest.raises(RolePromptPackInvariantError, match="duplicates"):
        _make(
            category_universe=("MOAT", "MOAT", "VALUATION"),
            min_distinct_categories=2,
        )


def test_category_universe_empty_raises() -> None:
    """TC-rpp-6b: Empty category_universe raises."""
    with pytest.raises(RolePromptPackInvariantError, match="category_universe"):
        _make(category_universe=(), min_distinct_categories=1)


# ---------------------------------------------------------------------------
# TC-rpp-7: model_id_preference validation
# ---------------------------------------------------------------------------


def test_model_id_preference_invalid_raises() -> None:
    """TC-rpp-7a: Unknown model name raises."""
    with pytest.raises(RolePromptPackInvariantError, match="model_id_preference"):
        _make(model_id_preference="gpt-4o")


def test_model_id_preference_none_accepted() -> None:
    """TC-rpp-7b: None is accepted (no preference)."""
    pack = _make(model_id_preference=None)
    assert pack.model_id_preference is None


def test_model_id_preference_sonnet_accepted() -> None:
    """TC-rpp-7c: claude-sonnet-4-6 is accepted."""
    pack = _make(model_id_preference="claude-sonnet-4-6")
    assert pack.model_id_preference == "claude-sonnet-4-6"


def test_model_id_preference_opus_accepted() -> None:
    """TC-rpp-7d: claude-opus-4-7 is accepted."""
    pack = _make(model_id_preference="claude-opus-4-7")
    assert pack.model_id_preference == "claude-opus-4-7"


def test_model_id_preference_haiku_accepted() -> None:
    """TC-rpp-7e: claude-haiku-4-5 is accepted."""
    pack = _make(model_id_preference="claude-haiku-4-5")
    assert pack.model_id_preference == "claude-haiku-4-5"


# ---------------------------------------------------------------------------
# TC-rpp-8: frozen invariant
# ---------------------------------------------------------------------------


def test_frozen_invariant_raises_on_assignment() -> None:
    """TC-rpp-8: Attempting to set field after construction raises FrozenInstanceError."""
    pack = _make()
    with pytest.raises((dataclasses.FrozenInstanceError, AttributeError)):
        pack.role_id = "other"  # type: ignore[misc]
