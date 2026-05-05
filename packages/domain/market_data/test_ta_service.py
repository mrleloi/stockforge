"""Tests for TA service — deterministic indicator computation.

Pure-domain; no IO, no fixtures. Hand-crafted bar series exercise edge cases
(insufficient history → None; flat series → RSI=100 / vol=0; rallying series
→ RSI > 50; selling series → RSI < 50).
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from decimal import Decimal

from packages.domain.market_data.services.ta_service import (
    TAFeatures,
    compute_ta_features,
)


@dataclass(frozen=True)
class _Money:
    amount: Decimal


@dataclass(frozen=True)
class _Bar:
    close: _Money


def _series(values: list[float]) -> list[_Bar]:
    return [_Bar(_Money(Decimal(str(v)))) for v in values]


def test_insufficient_history_all_none() -> None:
    feats = compute_ta_features(_series([100.0] * 5))
    assert feats.sma_20 is None
    assert feats.sma_50 is None
    assert feats.sma_200 is None
    assert feats.rsi_14 is None
    assert feats.realized_vol_90d_annualized is None
    assert feats.bollinger_position is None
    # pct_off_52w_high uses available window; with 5 bars all=100 → 0.0
    assert feats.pct_off_52w_high == Decimal("0.000000")


def test_sma_20_50() -> None:
    closes = list(range(1, 51))  # 1..50
    feats = compute_ta_features(_series([float(x) for x in closes]))
    # SMA-20 = mean(31..50) = 40.5
    assert feats.sma_20 == Decimal("40.500000")
    # SMA-50 = mean(1..50) = 25.5
    assert feats.sma_50 == Decimal("25.500000")
    # SMA-200 needs 200 bars
    assert feats.sma_200 is None


def test_rsi_flat_returns_100() -> None:
    feats = compute_ta_features(_series([100.0] * 20))
    # No losses → RSI = 100 by Wilder convention
    assert feats.rsi_14 == Decimal("100.0000")


def test_rsi_rally_above_50() -> None:
    # Strictly increasing → all gains, no losses → RSI = 100
    closes = [float(x) for x in range(100, 130)]
    feats = compute_ta_features(_series(closes))
    assert feats.rsi_14 == Decimal("100.0000")


def test_rsi_selloff_below_50() -> None:
    # Strictly decreasing → all losses, no gains → RSI = 0
    closes = [float(x) for x in range(150, 100, -1)]
    feats = compute_ta_features(_series(closes))
    assert feats.rsi_14 == Decimal("0.0000")


def test_rsi_mixed_in_band() -> None:
    # Alternate gain/loss of equal magnitude → RS = 1 → RSI = 50
    closes = [100.0]
    for i in range(20):
        if i % 2 == 0:
            closes.append(closes[-1] + 1)
        else:
            closes.append(closes[-1] - 1)
    feats = compute_ta_features(_series(closes))
    assert feats.rsi_14 == Decimal("50.0000")


def test_realized_vol_flat_zero() -> None:
    feats = compute_ta_features(_series([100.0] * 100))
    assert feats.realized_vol_90d_annualized == Decimal("0.000000")


def test_realized_vol_known_pattern() -> None:
    # +1% / -1% alternation — log-return sigma ~0.01 → annualized ~0.01 * sqrt(252) ≈ 0.1587
    closes = [100.0]
    for i in range(100):
        closes.append(closes[-1] * (1.01 if i % 2 == 0 else 1.0 / 1.01))
    feats = compute_ta_features(_series(closes))
    assert feats.realized_vol_90d_annualized is not None
    val = float(feats.realized_vol_90d_annualized)
    expected = math.log(1.01) * math.sqrt(252)
    assert abs(val - expected) < 0.005


def test_bollinger_position_above_band() -> None:
    # Last close far above 20-period mean — z-score should be positive
    closes = [100.0] * 19 + [120.0]
    feats = compute_ta_features(_series(closes))
    assert feats.bollinger_position is not None
    assert feats.bollinger_position > Decimal("0")


def test_pct_off_52w_high_negative_when_below_max() -> None:
    closes = [200.0] + [100.0] * 100  # max=200, current=100 → -0.5
    feats = compute_ta_features(_series(closes))
    assert feats.pct_off_52w_high == Decimal("-0.500000")


def test_pct_off_52w_high_zero_at_high() -> None:
    closes = [100.0] * 100 + [200.0]  # current is the max
    feats = compute_ta_features(_series(closes))
    assert feats.pct_off_52w_high == Decimal("0.000000")


def test_audit_formulas_present_for_every_feature() -> None:
    feats = compute_ta_features(_series([100.0] * 250))
    for key in (
        "sma_N",
        "rsi_14",
        "realized_vol_90d_annualized",
        "bollinger_position",
        "pct_off_52w_high",
    ):
        assert key in feats.audit
        assert len(feats.audit[key]) > 5  # non-trivial formula text


def test_to_dict_drops_none_values() -> None:
    feats = compute_ta_features(_series([100.0] * 5))
    d = feats.to_dict()
    # All numeric features None except pct_off_52w_high (which is 0.0 here)
    assert "sma_20" not in d
    assert "rsi_14" not in d
    assert "pct_off_52w_high" in d


def test_to_dict_includes_all_when_full_history() -> None:
    feats = compute_ta_features(_series([100.0 + i for i in range(250)]))
    d = feats.to_dict()
    for k in ("sma_20", "sma_50", "sma_200", "rsi_14",
              "realized_vol_90d_annualized", "bollinger_position",
              "pct_off_52w_high"):
        assert k in d


def test_dataclass_frozen() -> None:
    feats: TAFeatures = compute_ta_features(_series([100.0] * 30))
    try:
        feats.sma_20 = Decimal("0")  # type: ignore[misc]
    except Exception:
        return
    raise AssertionError("TAFeatures should be frozen")
