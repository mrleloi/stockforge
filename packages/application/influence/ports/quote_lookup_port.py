"""QuoteLookupPort — application Protocol for point-in-time price lookup.

S49 wires a stub by default; a Phase 4 wiring task connects this port to the
BC-1 market_data quote repository when its closing-price API stabilizes.
"""

from __future__ import annotations

from datetime import date
from typing import Protocol

__all__ = ["QuoteLookupPort"]


class QuoteLookupPort(Protocol):
    """Point-in-time closing price lookup for a VN ticker."""

    async def get_close_on(self, *, ticker: str, on: date) -> float | None:
        """Return the official closing price (VND) for ticker on date.

        Returns None when no price is available (non-trading day, ticker
        not yet listed, etc.). Implementations must NOT extrapolate — UC-2
        callers are expected to skip evaluation when None comes back.
        """
        ...
