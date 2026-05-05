"""Ticker — VN equity symbol value object.

Phase 1 scope: HOSE + HNX + UPCoM listed equities. All VN tickers are
3-character codes (A-Z or 0-9). Examples:
- HOSE: VHM, VIC, VPB, HPG, FPT, MWG (3 uppercase letters)
- HNX:  ACB, SHB, PVS (3 uppercase letters)
- UPCoM: BSR, MSR (3 uppercase letters); mixed alphanumeric also exists

Per agent-workspace/ubiquitous-language/glossary.md v1.0 (S25 output) §
"Ticker" entry: 3-character code, A-Z + 0-9, case-normalized to uppercase.

Source: PROJECT_CHARTER.md § First Sub-Scope ("HOSE/HNX/UPCoM"); validated
by glossary v1.0; binding from Phase 1 entry 2026-04-30.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

__all__ = ["Ticker", "InvalidTickerError"]


_TICKER_PATTERN = re.compile(r"^[A-Z0-9]{3}$")


class InvalidTickerError(ValueError):
    """Raised when a ticker symbol fails VN-format validation."""

    def __init__(self, raw: str, reason: str) -> None:
        super().__init__(f"invalid ticker {raw!r}: {reason}")
        self.raw = raw
        self.reason = reason


@dataclass(frozen=True, slots=True)
class Ticker:
    """Immutable VN equity ticker symbol. Case-normalized to uppercase.

    Validates 3-character A-Z/0-9 pattern in __post_init__. Construction with
    any other shape raises InvalidTickerError — invalid states are
    unrepresentable per architecture.md § Domain Model Rules.
    """

    symbol: str

    def __post_init__(self) -> None:
        if not isinstance(self.symbol, str):
            raise InvalidTickerError(
                str(self.symbol), f"expected str, got {type(self.symbol).__name__}"
            )
        upper = self.symbol.upper()
        if not _TICKER_PATTERN.match(upper):
            raise InvalidTickerError(
                self.symbol,
                "must be exactly 3 characters of A-Z or 0-9 (VN HOSE/HNX/UPCoM convention)",
            )
        if upper != self.symbol:
            object.__setattr__(self, "symbol", upper)

    def __str__(self) -> str:
        return self.symbol
