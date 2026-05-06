"""KolStatus — lifecycle state of a KOL in the influence network.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § A.3 BR-2.
5 values per spec.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["KolStatus"]


class KolStatus(StrEnum):
    """Lifecycle state of a KOL entity.

    PROVISIONAL  — new KOL; not yet counted in confluence (BR-2: awaiting 10 evaluated recs).
    ACTIVE       — credibility established; participates in confluence detection.
    PAUSED       — channel temporarily inactive; not scraped.
    RETIRED      — channel permanently stopped; historical data preserved.
    BLACKLISTED  — confirmed pumper or TOS violation; requires human confirmation (BR-B.8).
    """

    PROVISIONAL = "provisional"
    ACTIVE = "active"
    PAUSED = "paused"
    RETIRED = "retired"
    BLACKLISTED = "blacklisted"
