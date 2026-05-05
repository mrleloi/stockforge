"""Fixture-based tests for S28 ingestion adapters.

NO live API calls — every adapter uses an injected http_get_fn or
quote_history_fn returning recorded responses. Adheres to architecture.md §
Testing fixture discipline + master-plan 004 § S28 success criteria #3.
"""

from __future__ import annotations

from datetime import UTC, date, datetime, timedelta
from decimal import Decimal
from pathlib import Path

import pytest

from packages.contracts import (
    AdjustmentType,
    Currency,
    CurrencyMismatchError,
    Money,
    SourceProvider,
    Ticker,
)
from packages.domain.market_data.models import Bar
from packages.infrastructure.market_data import (
    ReconciliationConfidence,
    ReconciliationService,
    SqliteBarRepository,
    SsiAdapter,
    SsiApiError,
    TcbsAdapter,
    TcbsApiError,
    VnstockAdapter,
)

# ---------------------------------------------------------------------------
# helpers


def _bar(
    *,
    ticker: str = "VHM",
    period_end: date,
    close_amount: str = "120000",
    source: SourceProvider = SourceProvider.VNSTOCK,
    adjustment: AdjustmentType = AdjustmentType.BOTH,
    currency: Currency = Currency.VND,
) -> Bar:
    return Bar(
        ticker=Ticker(ticker),
        period_end=period_end,
        filing_date=period_end,
        ingested_at=datetime(2026, 4, 30, 12, 0, tzinfo=UTC),
        open=Money(Decimal(close_amount), currency),
        high=Money(Decimal(close_amount) + Decimal("500"), currency),
        low=Money(Decimal(close_amount) - Decimal("500"), currency),
        close=Money(Decimal(close_amount), currency),
        volume=1_000_000,
        foreign_buy=0,
        foreign_sell=0,
        adjustment_type=adjustment,
        source_provider=source,
    )


class _FakeDataFrame:
    """Minimal DataFrame stand-in for VnstockAdapter tests."""

    def __init__(self, rows: list[dict[str, object]]) -> None:
        self.rows = rows
        self.columns = list(rows[0].keys()) if rows else []

    def iterrows(self) -> object:
        return iter([(i, r) for i, r in enumerate(self.rows)])


class _FakeResponse:
    def __init__(self, status_code: int, payload: object) -> None:
        self.status_code = status_code
        self._payload = payload

    def json(self) -> object:
        return self._payload


# ---------------------------------------------------------------------------
# VnstockAdapter tests


class TestVnstockAdapter:
    def _adapter(self, df: object) -> VnstockAdapter:
        return VnstockAdapter(quote_history_fn=lambda **_kw: df, rate_limit_seconds=0)

    def test_fetch_maps_dataframe_to_bars(self) -> None:
        df = _FakeDataFrame(
            [
                {"time": date(2026, 4, 28), "open": 124.0, "high": 124.5, "low": 122.0, "close": 123.5, "volume": 2_500_000},
                {"time": date(2026, 4, 29), "open": 123.5, "high": 125.0, "low": 122.0, "close": 124.0, "volume": 3_100_000},
            ]
        )
        bars = self._adapter(df).fetch_daily(Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30))
        assert len(bars) == 2
        assert bars[0].close.amount == Decimal("123500")  # thousand VND multiplier
        assert bars[0].source_provider == SourceProvider.VNSTOCK
        assert bars[0].adjustment_type == AdjustmentType.BOTH

    def test_filters_outside_range(self) -> None:
        df = _FakeDataFrame(
            [
                {"time": date(2026, 1, 1), "open": 100.0, "high": 100.0, "low": 100.0, "close": 100.0, "volume": 1},
                {"time": date(2026, 4, 15), "open": 120.0, "high": 121.0, "low": 119.0, "close": 120.5, "volume": 2},
            ]
        )
        bars = self._adapter(df).fetch_daily(Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30))
        assert len(bars) == 1
        assert bars[0].period_end == date(2026, 4, 15)

    def test_filters_future_dates(self) -> None:
        future = date.today() + timedelta(days=10)
        df = _FakeDataFrame(
            [{"time": future, "open": 100.0, "high": 100.0, "low": 100.0, "close": 100.0, "volume": 1}]
        )
        bars = self._adapter(df).fetch_daily(Ticker("VHM"), date(2026, 1, 1), future + timedelta(days=1))
        assert bars == []

    def test_invalid_start_after_end(self) -> None:
        with pytest.raises(ValueError, match="start"):
            self._adapter(_FakeDataFrame([])).fetch_daily(Ticker("VHM"), date(2026, 4, 30), date(2026, 4, 1))

    def test_thousand_vnd_multiplier(self) -> None:
        df = _FakeDataFrame(
            [{"time": date(2026, 4, 15), "open": 100.5, "high": 101.0, "low": 100.0, "close": 100.7, "volume": 5}]
        )
        bars = self._adapter(df).fetch_daily(Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30))
        assert bars[0].close.amount == Decimal("100700.0")
        assert bars[0].open.amount == Decimal("100500.0")


# ---------------------------------------------------------------------------
# TcbsAdapter tests


class TestTcbsAdapter:
    def _adapter(self, response: _FakeResponse) -> TcbsAdapter:
        return TcbsAdapter(http_get_fn=lambda _url, _params: response, rate_limit_seconds=0)

    def test_fetch_maps_payload_to_bars(self) -> None:
        payload = {
            "data": [
                {"open": 124000, "high": 124500, "low": 122000, "close": 123500, "volume": 2_500_000, "tradingDate": "2026-04-28T00:00:00.000Z"},
                {"open": 123500, "high": 125000, "low": 122000, "close": 124000, "volume": 3_100_000, "tradingDate": "2026-04-29T00:00:00.000Z"},
            ],
            "ticker": "VHM",
        }
        bars = self._adapter(_FakeResponse(200, payload)).fetch_daily(Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30))
        assert len(bars) == 2
        assert bars[0].close.amount == Decimal("123500")
        assert bars[0].source_provider == SourceProvider.TCBS

    def test_non_200_raises_TcbsApiError(self) -> None:
        with pytest.raises(TcbsApiError, match="status"):
            self._adapter(_FakeResponse(500, {})).fetch_daily(Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30))

    def test_unexpected_payload_raises(self) -> None:
        with pytest.raises(TcbsApiError, match="payload shape"):
            self._adapter(_FakeResponse(200, ["not", "a", "dict"])).fetch_daily(Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30))

    def test_filters_outside_range(self) -> None:
        payload = {
            "data": [
                {"open": 1, "high": 1, "low": 1, "close": 1, "volume": 1, "tradingDate": "2026-01-15T00:00:00.000Z"},
                {"open": 2, "high": 2, "low": 2, "close": 2, "volume": 2, "tradingDate": "2026-04-15T00:00:00.000Z"},
            ]
        }
        bars = self._adapter(_FakeResponse(200, payload)).fetch_daily(Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30))
        assert len(bars) == 1
        assert bars[0].period_end == date(2026, 4, 15)

    def test_invalid_start_after_end(self) -> None:
        with pytest.raises(ValueError, match="start"):
            self._adapter(_FakeResponse(200, {"data": []})).fetch_daily(
                Ticker("VHM"), date(2026, 4, 30), date(2026, 4, 1)
            )


# ---------------------------------------------------------------------------
# SsiAdapter tests (S32 Track A R2 closure; D-012 A3 strategy)


class TestSsiAdapter:
    def _adapter(self, response: _FakeResponse) -> SsiAdapter:
        return SsiAdapter(http_get_fn=lambda _url, _params: response, rate_limit_seconds=0)

    def _payload(self, t_epochs: list[int], closes: list[float]) -> dict[str, object]:
        n = len(t_epochs)
        return {
            "code": "SUCCESS",
            "message": "ok",
            "data": {
                "t": list(t_epochs),
                "o": [c - 0.5 for c in closes],
                "h": [c + 0.3 for c in closes],
                "l": [c - 0.7 for c in closes],
                "c": list(closes),
                "v": [1_000_000 + i for i in range(n)],
                "s": "ok",
                "nextTime": None,
            },
        }

    def test_fetch_maps_payload_to_bars_thousand_vnd(self) -> None:
        # 2026-04-28 UTC midnight, 2026-04-29 UTC midnight
        t1 = int(datetime(2026, 4, 28, tzinfo=UTC).timestamp())
        t2 = int(datetime(2026, 4, 29, tzinfo=UTC).timestamp())
        payload = self._payload([t1, t2], [123.5, 124.0])
        bars = self._adapter(_FakeResponse(200, payload)).fetch_daily(
            Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
        )
        assert len(bars) == 2
        # thousand-VND multiplier (123.5 → 123500)
        assert bars[0].close.amount == Decimal("123500.0")
        assert bars[0].source_provider == SourceProvider.SSI
        assert bars[0].adjustment_type == AdjustmentType.BOTH
        assert bars[0].volume == 1_000_000

    def test_non_200_raises_SsiApiError(self) -> None:
        with pytest.raises(SsiApiError, match="status"):
            self._adapter(_FakeResponse(503, {})).fetch_daily(
                Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
            )

    def test_unexpected_payload_shape_raises(self) -> None:
        with pytest.raises(SsiApiError, match="payload shape"):
            self._adapter(_FakeResponse(200, ["not", "a", "dict"])).fetch_daily(
                Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
            )

    def test_missing_data_key_raises(self) -> None:
        with pytest.raises(SsiApiError, match="payload shape"):
            self._adapter(_FakeResponse(200, {"code": "SUCCESS"})).fetch_daily(
                Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
            )

    def test_data_not_dict_raises(self) -> None:
        with pytest.raises(SsiApiError, match="data shape"):
            self._adapter(_FakeResponse(200, {"data": "string-not-dict"})).fetch_daily(
                Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
            )

    def test_array_length_mismatch_raises(self) -> None:
        bad = {
            "data": {
                "t": [1, 2, 3],
                "o": [1.0, 2.0],
                "h": [1.0, 2.0, 3.0],
                "l": [1.0, 2.0, 3.0],
                "c": [1.0, 2.0, 3.0],
                "v": [1, 2, 3],
            }
        }
        with pytest.raises(SsiApiError, match="length mismatch"):
            self._adapter(_FakeResponse(200, bad)).fetch_daily(
                Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
            )

    def test_filters_outside_range(self) -> None:
        early = int(datetime(2026, 1, 15, tzinfo=UTC).timestamp())
        inside = int(datetime(2026, 4, 15, tzinfo=UTC).timestamp())
        payload = self._payload([early, inside], [100.0, 120.0])
        bars = self._adapter(_FakeResponse(200, payload)).fetch_daily(
            Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
        )
        assert len(bars) == 1
        assert bars[0].period_end == date(2026, 4, 15)

    def test_invalid_start_after_end(self) -> None:
        with pytest.raises(ValueError, match="start"):
            self._adapter(_FakeResponse(200, {"data": {}})).fetch_daily(
                Ticker("VHM"), date(2026, 4, 30), date(2026, 4, 1)
            )

    def test_empty_data_returns_empty_list(self) -> None:
        payload: dict[str, object] = {"data": {"t": [], "o": [], "h": [], "l": [], "c": [], "v": []}}
        bars = self._adapter(_FakeResponse(200, payload)).fetch_daily(
            Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
        )
        assert bars == []

    def test_bars_sorted_ascending_by_period_end(self) -> None:
        # supply unsorted timestamps; adapter must sort ascending
        t_late = int(datetime(2026, 4, 29, tzinfo=UTC).timestamp())
        t_mid = int(datetime(2026, 4, 28, tzinfo=UTC).timestamp())
        t_early = int(datetime(2026, 4, 27, tzinfo=UTC).timestamp())
        payload = self._payload([t_late, t_early, t_mid], [124.0, 122.0, 123.0])
        bars = self._adapter(_FakeResponse(200, payload)).fetch_daily(
            Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
        )
        assert [b.period_end for b in bars] == [
            date(2026, 4, 27),
            date(2026, 4, 28),
            date(2026, 4, 29),
        ]

    def test_emits_source_provider_SSI(self) -> None:
        # Specific Rule 4 enforcement: every emitted bar tagged SourceProvider.SSI
        t = int(datetime(2026, 4, 28, tzinfo=UTC).timestamp())
        payload = self._payload([t], [100.0])
        bars = self._adapter(_FakeResponse(200, payload)).fetch_daily(
            Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
        )
        assert all(b.source_provider == SourceProvider.SSI for b in bars)

    def test_volume_coerced_to_int(self) -> None:
        t = int(datetime(2026, 4, 28, tzinfo=UTC).timestamp())
        payload = {"data": {"t": [t], "o": [1.0], "h": [1.0], "l": [1.0], "c": [1.0], "v": [4570000.0]}}
        bars = self._adapter(_FakeResponse(200, payload)).fetch_daily(
            Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
        )
        assert bars[0].volume == 4_570_000
        assert isinstance(bars[0].volume, int)

    def test_decimal_thousand_multiplier_precision(self) -> None:
        t = int(datetime(2026, 4, 28, tzinfo=UTC).timestamp())
        payload = self._payload([t], [41.15])
        bars = self._adapter(_FakeResponse(200, payload)).fetch_daily(
            Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30)
        )
        assert bars[0].close.amount == Decimal("41150.00")  # 41.15 * 1000
        assert bars[0].close.currency == Currency.VND


# ---------------------------------------------------------------------------
# Cross-source reconciliation tests (S32 Track A — Rule 4 dual-source)


class TestCrossSourceReconciliation:
    """Verify VnstockAdapter (VCI) + SsiAdapter (iBoard) yield reconcilable Bars."""

    def test_vci_vs_ssi_within_tolerance_HIGH(self) -> None:
        d = date(2026, 4, 28)
        vci = [_bar(period_end=d, close_amount="100000", source=SourceProvider.VNSTOCK)]
        ssi = [_bar(period_end=d, close_amount="100500", source=SourceProvider.SSI)]
        rows = ReconciliationService().reconcile(vci, ssi)
        assert len(rows) == 1
        assert rows[0].confidence == ReconciliationConfidence.HIGH
        assert rows[0].sources_present == (SourceProvider.VNSTOCK, SourceProvider.SSI)
        assert rows[0].close_reconciled.amount == Decimal("100250")

    def test_vci_only_emits_SINGLE_SOURCE_VNSTOCK(self) -> None:
        d = date(2026, 4, 28)
        rows = ReconciliationService().reconcile(
            [_bar(period_end=d, source=SourceProvider.VNSTOCK)], []
        )
        assert rows[0].confidence == ReconciliationConfidence.SINGLE_SOURCE
        assert rows[0].sources_present == (SourceProvider.VNSTOCK,)

    def test_ssi_only_emits_SINGLE_SOURCE_SSI(self) -> None:
        d = date(2026, 4, 28)
        rows = ReconciliationService().reconcile(
            [], [_bar(period_end=d, source=SourceProvider.SSI)]
        )
        assert rows[0].confidence == ReconciliationConfidence.SINGLE_SOURCE
        assert rows[0].sources_present == (SourceProvider.SSI,)


# ---------------------------------------------------------------------------
# ReconciliationService tests


class TestReconciliationService:
    def test_within_1pct_HIGH_confidence_mean(self) -> None:
        d = date(2026, 4, 28)
        primary = [_bar(period_end=d, close_amount="100000")]
        secondary = [_bar(period_end=d, close_amount="100500", source=SourceProvider.TCBS)]
        rows = ReconciliationService().reconcile(primary, secondary)
        assert len(rows) == 1
        assert rows[0].confidence == ReconciliationConfidence.HIGH
        assert rows[0].close_reconciled.amount == Decimal("100250")  # mean

    def test_outside_1pct_LOW_confidence_uses_primary(self) -> None:
        d = date(2026, 4, 28)
        primary = [_bar(period_end=d, close_amount="100000")]
        secondary = [_bar(period_end=d, close_amount="105000", source=SourceProvider.TCBS)]
        rows = ReconciliationService().reconcile(primary, secondary)
        assert rows[0].confidence == ReconciliationConfidence.LOW
        assert rows[0].close_reconciled.amount == Decimal("100000")  # primary kept

    def test_only_primary_present_SINGLE_SOURCE(self) -> None:
        rows = ReconciliationService().reconcile([_bar(period_end=date(2026, 4, 28))], [])
        assert rows[0].confidence == ReconciliationConfidence.SINGLE_SOURCE
        assert rows[0].sources_present == (SourceProvider.VNSTOCK,)

    def test_only_secondary_present_SINGLE_SOURCE(self) -> None:
        rows = ReconciliationService().reconcile(
            [], [_bar(period_end=date(2026, 4, 28), source=SourceProvider.TCBS)]
        )
        assert rows[0].confidence == ReconciliationConfidence.SINGLE_SOURCE
        assert rows[0].sources_present == (SourceProvider.TCBS,)

    def test_currency_mismatch_raises(self) -> None:
        d = date(2026, 4, 28)
        primary = [_bar(period_end=d, close_amount="100000", currency=Currency.VND)]
        secondary = [_bar(period_end=d, close_amount="100", source=SourceProvider.TCBS, currency=Currency.USD)]
        with pytest.raises(CurrencyMismatchError):
            ReconciliationService().reconcile(primary, secondary)


# ---------------------------------------------------------------------------
# SqliteBarRepository tests


class TestSqliteBarRepository:
    def _repo(self, tmp_path: Path) -> SqliteBarRepository:
        return SqliteBarRepository(db_path=tmp_path / "bars.sqlite")

    def test_save_then_get_latest(self, tmp_path: Path) -> None:
        repo = self._repo(tmp_path)
        bars = [_bar(period_end=date(2026, 4, 28)), _bar(period_end=date(2026, 4, 29))]
        repo.save_many(bars)
        latest = repo.get_latest(Ticker("VHM"))
        assert latest is not None
        assert latest.period_end == date(2026, 4, 29)

    def test_get_as_of_filters_by_filing_date(self, tmp_path: Path) -> None:
        repo = self._repo(tmp_path)
        repo.save_many(
            [_bar(period_end=date(2026, 4, 15)), _bar(period_end=date(2026, 4, 25))]
        )
        as_of = repo.get_as_of(Ticker("VHM"), date(2026, 4, 20))
        assert len(as_of) == 1
        assert as_of[0].period_end == date(2026, 4, 15)

    def test_get_range_adjusted_BOTH_only(self, tmp_path: Path) -> None:
        repo = self._repo(tmp_path)
        repo.save_many(
            [
                _bar(period_end=date(2026, 4, 15), adjustment=AdjustmentType.BOTH),
                _bar(period_end=date(2026, 4, 16), adjustment=AdjustmentType.NONE),
            ]
        )
        rows = repo.get_range_adjusted(Ticker("VHM"), date(2026, 4, 1), date(2026, 4, 30))
        assert len(rows) == 1
        assert rows[0].adjustment_type == AdjustmentType.BOTH

    def test_save_many_idempotent(self, tmp_path: Path) -> None:
        repo = self._repo(tmp_path)
        b = _bar(period_end=date(2026, 4, 28))
        repo.save_many([b])
        repo.save_many([b])
        assert repo.count() == 1

    def test_dedupe_prefers_VNSTOCK_over_TCBS(self, tmp_path: Path) -> None:
        repo = self._repo(tmp_path)
        d = date(2026, 4, 28)
        repo.save_many(
            [
                _bar(period_end=d, close_amount="100000", source=SourceProvider.VNSTOCK),
                _bar(period_end=d, close_amount="100500", source=SourceProvider.TCBS),
            ]
        )
        latest = repo.get_latest(Ticker("VHM"))
        assert latest is not None
        assert latest.source_provider == SourceProvider.VNSTOCK
        assert repo.count() == 2  # both rows persisted; read dedupes

    def test_decimal_precision_preserved(self, tmp_path: Path) -> None:
        repo = self._repo(tmp_path)
        precise = _bar(period_end=date(2026, 4, 28), close_amount="123456.789")
        repo.save_many([precise])
        latest = repo.get_latest(Ticker("VHM"))
        assert latest is not None
        assert latest.close.amount == Decimal("123456.789")


# ---------------------------------------------------------------------------
# VN30 universe tests (S33 Track B — BC-1 expansion)


class TestVn30Universe:
    """Verify the frozen VN30 universe value object meets index invariants."""

    def test_exactly_30_constituents(self) -> None:
        from packages.domain.market_data import VN30_UNIVERSE
        assert len(VN30_UNIVERSE) == 30

    def test_all_tickers_unique(self) -> None:
        from packages.domain.market_data import VN30_UNIVERSE
        symbols = [c.ticker.symbol for c in VN30_UNIVERSE]
        assert len(set(symbols)) == 30

    def test_all_constituents_HOSE(self) -> None:
        from packages.domain.market_data import VN30_UNIVERSE
        # VN30 is HOSE-only by index construction (amendment-VN Rule 14 S33 lock)
        assert all(c.sàn == "HOSE" for c in VN30_UNIVERSE)

    def test_vn30_tickers_helper_returns_alphabetical_order(self) -> None:
        from packages.domain.market_data import vn30_tickers
        tickers = vn30_tickers()
        symbols = [t.symbol for t in tickers]
        assert symbols == sorted(symbols), "VN30 should canonicalise alphabetically"

    def test_known_anchor_tickers_present(self) -> None:
        # Sanity-check anchor blue chips that have been in VN30 since 2018
        # (cross-checked against data/vn30-probe-ssi.json S32 30/30 probe)
        from packages.domain.market_data import vn30_tickers
        symbols = {t.symbol for t in vn30_tickers()}
        for anchor in ("VHM", "VIC", "VCB", "FPT", "HPG", "VPB"):
            assert anchor in symbols, f"VN30 anchor {anchor} missing"


# ---------------------------------------------------------------------------
# Sàn-tier tolerance tests (S33 Track B — amendment-VN Rule 14 wiring)


class TestSanTierTolerance:
    def test_default_tolerance_when_bar_has_no_san_field(self) -> None:
        # Bar entity does not yet carry sàn (amendment-VN PROPOSAL); should
        # fall back to service.tolerance (1% HOSE baseline).
        svc = ReconciliationService()
        b = _bar(period_end=date(2026, 4, 28))
        assert svc.tolerance_for(b) == Decimal("0.01")

    def test_custom_service_tolerance_propagates(self) -> None:
        svc = ReconciliationService(tolerance=Decimal("0.005"))
        b = _bar(period_end=date(2026, 4, 28))
        assert svc.tolerance_for(b) == Decimal("0.005")


# ---------------------------------------------------------------------------
# Multi-ticker batched insert tests (S33 Track B — VN30 nightly batch)


class TestMultiTickerBatchedInsert:
    def _repo(self, tmp_path: Path) -> SqliteBarRepository:
        return SqliteBarRepository(db_path=tmp_path / "vn30.sqlite")

    def test_save_many_by_ticker_persists_each_ticker(self, tmp_path: Path) -> None:
        repo = self._repo(tmp_path)
        d = date(2026, 4, 28)
        bars_by_ticker = {
            Ticker("VHM"): [_bar(ticker="VHM", period_end=d)],
            Ticker("VIC"): [_bar(ticker="VIC", period_end=d)],
            Ticker("FPT"): [_bar(ticker="FPT", period_end=d)],
        }
        result = repo.save_many_by_ticker(bars_by_ticker)
        assert result == {Ticker("VHM"): 1, Ticker("VIC"): 1, Ticker("FPT"): 1}
        assert repo.count() == 3

    def test_save_many_by_ticker_empty_ticker_returns_zero(self, tmp_path: Path) -> None:
        repo = self._repo(tmp_path)
        result = repo.save_many_by_ticker({Ticker("VHM"): []})
        assert result == {Ticker("VHM"): 0}
        assert repo.count() == 0

    def test_count_for_filters_by_ticker(self, tmp_path: Path) -> None:
        repo = self._repo(tmp_path)
        d1 = date(2026, 4, 28)
        d2 = date(2026, 4, 29)
        repo.save_many_by_ticker({
            Ticker("VHM"): [_bar(ticker="VHM", period_end=d1), _bar(ticker="VHM", period_end=d2)],
            Ticker("VIC"): [_bar(ticker="VIC", period_end=d1)],
        })
        assert repo.count_for(Ticker("VHM")) == 2
        assert repo.count_for(Ticker("VIC")) == 1
        assert repo.count_for(Ticker("FPT")) == 0  # not ingested

    def test_save_many_by_ticker_per_ticker_isolation(self, tmp_path: Path) -> None:
        # Partial-failure tolerance: success on one ticker should persist even
        # if a separate call would have failed.
        repo = self._repo(tmp_path)
        d = date(2026, 4, 28)
        result = repo.save_many_by_ticker({
            Ticker("VHM"): [_bar(ticker="VHM", period_end=d)],
            Ticker("VIC"): [],
        })
        assert result[Ticker("VHM")] == 1
        assert result[Ticker("VIC")] == 0
        assert repo.count_for(Ticker("VHM")) == 1
