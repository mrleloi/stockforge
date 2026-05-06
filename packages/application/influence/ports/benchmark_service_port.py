"""BenchmarkServicePort — application Protocol for index returns over date ranges."""

from __future__ import annotations

from datetime import date
from typing import Protocol

__all__ = ["BenchmarkServicePort"]


class BenchmarkServicePort(Protocol):
    """Compute index return over a date range (used for excess-return math)."""

    async def get_index_return(
        self, *, index: str, from_date: date, to_date: date
    ) -> float | None:
        """Return index return as a decimal fraction (0.05 = +5%) or None if missing.

        `index` is typically "VN-INDEX". Implementations must use the official
        close on each boundary date; if either close is unavailable the function
        returns None rather than fabricating a value.
        """
        ...
