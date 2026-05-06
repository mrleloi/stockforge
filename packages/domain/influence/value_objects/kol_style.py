"""KolStyle — classification of a KOL's analytical approach.

Source: specs/tier2-feature/002-influence-network-tracking.md § A.3 BR-8.
5 values per spec + UNKNOWN for unclassified state.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["KolStyle"]


class KolStyle(StrEnum):
    """Analytical style classification for a KOL.

    FUNDAMENTAL — uses financial statements, valuation ratios.
    TECHNICAL    — uses chart patterns, indicators, price action.
    NARRATIVE    — uses stories, macro themes, momentum narratives.
    PUMPER       — detected pump operator (high frequency + dump pattern).
    MIXED        — combines multiple styles.
    UNKNOWN      — not yet classified (default for new KOLs).
    """

    FUNDAMENTAL = "fundamental"
    TECHNICAL = "technical"
    NARRATIVE = "narrative"
    PUMPER = "pumper"
    MIXED = "mixed"
    UNKNOWN = "unknown"
