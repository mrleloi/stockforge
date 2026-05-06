"""Timeframe — stated investment horizon for a KOL recommendation.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1.
5 values per spec.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["Timeframe"]


class Timeframe(StrEnum):
    """Stated investment horizon for a recommendation.

    Used to calibrate outcome evaluation thresholds (spec § UC-2):
    - INTRADAY   — within same trading day
    - DAYS       — 1-5 trading days; excess return threshold 3%
    - WEEKS      — 1-4 weeks; excess return threshold 5%
    - MONTHS     — 1-6 months; excess return threshold 10%
    - LONG_TERM  — 6+ months; excess return threshold 15%
    """

    INTRADAY = "intraday"
    DAYS = "days"
    WEEKS = "weeks"
    MONTHS = "months"
    LONG_TERM = "long_term"
