"""TA (technical analysis) feature service — deterministic indicators from bar history.

Pure-domain service. Computes a fixed set of momentum + volatility features that the
QUANT perspective agent interprets (it never computes them itself per I-S1).

Features (verbatim audit formulas in the audit dict):
- SMA-20 / SMA-50 / SMA-200: simple moving averages of close
- RSI-14: relative strength index, Wilder's smoothing (Hudson 1978 — formula:
  RS = avg_gain_14 / avg_loss_14;  RSI = 100 - 100 / (1 + RS))
- realized_vol_90d_annualized: stdev of daily log-returns over last 90 sessions
  scaled by sqrt(252) trading-day convention
- bollinger_position: (close - SMA-20) / (2 * stdev_20) — z-score relative to
  the upper/lower 2-sigma bands; > 1 means above upper band, < -1 below lower
- pct_off_52w_high: (close - max_close_252d) / max_close_252d — drawdown vs
  trailing 52-week high

Every feature degrades gracefully when bar history is insufficient (returns
None; caller surfaces this as a data-quality signal in SharedContext.gaps).

I-S1 compliance: this IS the deterministic Python tool. LLM never computes;
it only interprets the numbers + audit formulas this service emits.

Source: spec amendment candidate § A.10 (DEFER-S43b-5 — substrate-validation
arc S43b-EVIDENCE).
"""

from __future__ import annotations

import math
import statistics
from collections.abc import Sequence
from dataclasses import dataclass
from decimal import Decimal

__all__ = ["TAFeatures", "compute_ta_features"]


@dataclass(frozen=True, slots=True)
class TAFeatures:
    """Deterministic TA feature bundle.

    Each field is None when bar history is insufficient. `audit` carries the
    verbatim formula string per ratio for the I-S1 audit trail.
    """

    sma_20: Decimal | None
    sma_50: Decimal | None
    sma_200: Decimal | None
    rsi_14: Decimal | None
    realized_vol_90d_annualized: Decimal | None
    bollinger_position: Decimal | None
    pct_off_52w_high: Decimal | None
    audit: dict[str, str]

    def to_dict(self) -> dict[str, object]:
        """Flatten for SharedContext.ta_features serialization."""
        out: dict[str, object] = {}
        for name in (
            "sma_20", "sma_50", "sma_200",
            "rsi_14", "realized_vol_90d_annualized",
            "bollinger_position", "pct_off_52w_high",
        ):
            v = getattr(self, name)
            if v is not None:
                out[name] = v
        return out


def _to_float_closes(bars: Sequence[object]) -> list[float]:
    """Extract close as float — bars must be ASC by period_end (gatherer contract)."""
    out: list[float] = []
    for b in bars:
        close = getattr(b, "close", None)
        amt = getattr(close, "amount", close)
        if amt is None:
            continue
        out.append(float(amt))
    return out


def _q(value: float, places: int = 6) -> Decimal:
    """Quantize float to Decimal with fixed places. Avoids float repr noise in audit."""
    return Decimal(format(value, f".{places}f"))


def _sma(closes: list[float], window: int) -> Decimal | None:
    if len(closes) < window:
        return None
    window_slice = closes[-window:]
    return _q(sum(window_slice) / window)


def _rsi_14(closes: list[float]) -> Decimal | None:
    """Wilder's RSI-14. Needs ≥15 closes (14 deltas)."""
    if len(closes) < 15:
        return None
    deltas = [closes[i + 1] - closes[i] for i in range(len(closes) - 1)]
    recent = deltas[-14:]
    gains = [d for d in recent if d > 0]
    losses = [-d for d in recent if d < 0]
    avg_gain = sum(gains) / 14
    avg_loss = sum(losses) / 14
    if avg_loss == 0:
        return _q(100.0)
    rs = avg_gain / avg_loss
    rsi = 100.0 - 100.0 / (1.0 + rs)
    return _q(rsi, places=4)


def _realized_vol_annualized(closes: list[float]) -> Decimal | None:
    """Annualized stdev of last 90 daily log-returns × sqrt(252)."""
    if len(closes) < 91:
        return None
    window = closes[-91:]
    log_returns = [math.log(window[i + 1] / window[i]) for i in range(len(window) - 1)]
    sigma = statistics.stdev(log_returns)
    annualized = sigma * math.sqrt(252)
    return _q(annualized)


def _bollinger_position(closes: list[float]) -> Decimal | None:
    """z-score of close vs 20-period mean / 2σ."""
    if len(closes) < 20:
        return None
    window = closes[-20:]
    mean = sum(window) / 20
    sigma = statistics.stdev(window)
    if sigma == 0:
        return _q(0.0)
    z = (closes[-1] - mean) / (2 * sigma)
    return _q(z, places=4)


def _pct_off_52w_high(closes: list[float]) -> Decimal | None:
    """(close - max_252d) / max_252d. Negative means below 52w high."""
    if len(closes) < 1:
        return None
    window = closes[-252:] if len(closes) >= 252 else closes
    high = max(window)
    if high == 0:
        return None
    return _q((closes[-1] - high) / high, places=6)


def compute_ta_features(bars: Sequence[object]) -> TAFeatures:
    """Compute all TA features from a bar list (ASC by period_end)."""
    closes = _to_float_closes(bars)
    return TAFeatures(
        sma_20=_sma(closes, 20),
        sma_50=_sma(closes, 50),
        sma_200=_sma(closes, 200),
        rsi_14=_rsi_14(closes),
        realized_vol_90d_annualized=_realized_vol_annualized(closes),
        bollinger_position=_bollinger_position(closes),
        pct_off_52w_high=_pct_off_52w_high(closes),
        audit={
            "sma_N": "sum(closes[-N:]) / N — Hull TA Encyclopedia 2e §3",
            "rsi_14": "RS=avg_gain_14/avg_loss_14; RSI=100-100/(1+RS) — Wilder 1978",
            "realized_vol_90d_annualized": "stdev(log_returns[-90:]) * sqrt(252) — Hull Options 11e §15.4",
            "bollinger_position": "(close - SMA_20) / (2 * stdev_20) — Bollinger 2002",
            "pct_off_52w_high": "(close - max(closes[-252:])) / max(closes[-252:])",
        },
    )
