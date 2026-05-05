"""FinancialStatementFiled cross-BC event invariant tests (S34 Track C)."""

from __future__ import annotations

from datetime import UTC, date, datetime

import pytest

from packages.contracts import FinancialStatementFiled, SourceProvider, Ticker


def _evt(**overrides: object) -> FinancialStatementFiled:
    base: dict[str, object] = dict(
        ticker=Ticker("VHM"),
        statement_type="is",
        period_end=date(2026, 3, 31),
        filing_date=date(2026, 4, 30),
        source_provider=SourceProvider.VNSTOCK,
        emitted_at=datetime(2026, 4, 30, 12, 0, tzinfo=UTC),
    )
    base.update(overrides)
    return FinancialStatementFiled(**base)  # type: ignore[arg-type]


def test_event_constructs_with_valid_fields() -> None:
    e = _evt()
    assert e.ticker.symbol == "VHM"
    assert e.statement_type == "is"


def test_event_rejects_invalid_statement_type() -> None:
    with pytest.raises(ValueError, match="statement_type"):
        _evt(statement_type="other")


def test_event_rejects_filing_before_period_end() -> None:
    with pytest.raises(ValueError, match="Rule 1"):
        _evt(filing_date=date(2026, 3, 1))


def test_event_rejects_non_ticker() -> None:
    with pytest.raises(TypeError):
        FinancialStatementFiled(
            ticker="VHM",  # type: ignore[arg-type]
            statement_type="is",
            period_end=date(2026, 3, 31),
            filing_date=date(2026, 4, 30),
            source_provider=SourceProvider.VNSTOCK,
            emitted_at=datetime(2026, 4, 30, 12, 0, tzinfo=UTC),
        )


def test_event_is_frozen_hashable() -> None:
    e1 = _evt()
    e2 = _evt()
    assert hash(e1) == hash(e2)
    assert e1 == e2
