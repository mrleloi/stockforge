"""Window — 4-level StrEnum for sentiment snapshot time windows.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1.
ADR: D-032 § (c).
"""

from __future__ import annotations

from datetime import timedelta
from enum import StrEnum

__all__ = ["Window"]


class Window(StrEnum):
    """Time window for sentiment snapshot aggregation.

    Cadence notes (spec § B.7):
    - ONE_HOUR: F319 every 30min; snapshot aggregates 1h lookback
    - FOUR_HOUR: general intraday cadence
    - ONE_DAY: daily digest cadence
    - ONE_WEEK: trend cadence
    """

    ONE_HOUR = "1H"
    FOUR_HOUR = "4H"
    ONE_DAY = "1D"
    ONE_WEEK = "1W"

    @property
    def hours(self) -> float:
        """Duration of window in fractional hours. Used for posting_velocity computation."""
        _hours_map: dict[str, float] = {
            "1H": 1.0,
            "4H": 4.0,
            "1D": 24.0,
            "1W": 168.0,
        }
        return _hours_map[self.value]

    @property
    def duration(self) -> timedelta:
        """timedelta equivalent of window. Used for `from_time = now - window.duration`."""
        return timedelta(hours=self.hours)
