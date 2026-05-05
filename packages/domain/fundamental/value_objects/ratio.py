"""Ratio — derived valuation/efficiency metric value object.

Per spec-T1-001 § B.1 "LLM Role: NONE — calculations like P/E, ROE, DCF use
deterministic formulas in packages/domain/fundamental/services/". Each Ratio
carries the formula's textbook audit string so a thesis output can cite the
exact formula version with no LLM paraphrase (binds I-S1 + Rule 6).

Frozen dataclass — equality + hashability guaranteed by the decorator.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from decimal import Decimal
from enum import StrEnum

from packages.contracts import Ticker

from .statement_type import StatementType

__all__ = ["Ratio", "RatioName"]


class RatioName(StrEnum):
    """6 Phase-2 ratios per master-plan 005 § S34 deliverable #3.

    Phase 3 extends with ROIC, EV/EBITDA, FCF yield, etc. when Tier 2 thesis
    spec demands. Adding here without spec amendment violates I-S30.
    """

    PE = "PE"
    PB = "PB"
    ROE = "ROE"
    ROA = "ROA"
    DEBT_EQUITY = "DEBT_EQUITY"
    NET_MARGIN = "NET_MARGIN"


@dataclass(frozen=True, slots=True)
class Ratio:
    """Immutable computed ratio with full audit trail.

    `formula_audit` is a textbook citation (e.g., "Revenue / Net Income —
    Damodaran 'Investment Valuation' 3rd ed §10.2"). LLM consumers MUST cite
    this verbatim; LLM never re-derives nor paraphrases the formula.
    `computed_from` lists the StatementType inputs so a downstream verifier
    can replay the chain.
    """

    name: RatioName
    value: Decimal
    ticker: Ticker
    period_end: date
    formula_audit: str
    computed_from: tuple[StatementType, ...]

    def __post_init__(self) -> None:
        if not isinstance(self.value, Decimal):
            object.__setattr__(self, "value", Decimal(str(self.value)))
        if not self.formula_audit.strip():
            raise ValueError(f"Ratio {self.name} requires non-empty formula_audit (Rule 6 + I-S1)")
        if not self.computed_from:
            raise ValueError(f"Ratio {self.name} requires non-empty computed_from")
