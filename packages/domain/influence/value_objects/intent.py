"""Intent — directional recommendation intent extracted from KOL content.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § B.5.
6 values: STRONG_BUY | BUY | WATCH | NEUTRAL | AVOID | STRONG_AVOID.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["Intent"]


class Intent(StrEnum):
    """Directional intent of an extracted recommendation.

    Vietnamese nuances (per spec § B.5):
    - "mạnh tay mua" → STRONG_BUY
    - "mua" / "tích lũy" → BUY
    - "theo dõi" → WATCH
    - "trung lập" → NEUTRAL
    - "cẩn thận" → AVOID
    - "bán / tránh mạnh" → STRONG_AVOID
    """

    STRONG_BUY = "strong_buy"
    BUY = "buy"
    WATCH = "watch"
    NEUTRAL = "neutral"
    AVOID = "avoid"
    STRONG_AVOID = "strong_avoid"
