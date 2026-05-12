"""Value-object invariants for BC-9 outer-loop."""

from __future__ import annotations

from datetime import date

import pytest

from packages.domain.outer_loop.value_objects.eval_period import EvalPeriod


def test_eval_period_accepts_valid_range() -> None:
    p = EvalPeriod(start=date(2024, 1, 1), end=date(2024, 6, 30))
    assert p.start < p.end
    assert p.contains(date(2024, 4, 15))


def test_eval_period_accepts_single_day() -> None:
    p = EvalPeriod(start=date(2024, 1, 1), end=date(2024, 1, 1))
    assert p.contains(date(2024, 1, 1))


def test_eval_period_rejects_inverted_range() -> None:
    with pytest.raises(ValueError, match="must be <="):
        EvalPeriod(start=date(2024, 6, 30), end=date(2024, 1, 1))


def test_eval_period_contains_excludes_outside() -> None:
    p = EvalPeriod(start=date(2024, 1, 1), end=date(2024, 6, 30))
    assert not p.contains(date(2023, 12, 31))
    assert not p.contains(date(2024, 7, 1))
