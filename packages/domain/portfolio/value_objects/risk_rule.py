"""RiskRule — deterministic position-sizing + risk-management constants.

Per Charter Principle 10 ("Position sizing & risk management are deterministic
— code-enforced rules, LLM cannot override. Maximum position size, sector
concentration, stop loss rules are immutable per session.")

Defaults sourced from Charter § First Sub-Scope ("Position sizing per stock:
5-15% of portfolio") + spec 000 § A.10 Data Provenance:
- max_position_pct = 0.15 (Charter ceiling)
- max_sector_concentration_pct = 0.30 (Charter implicit)
- holding_period_min_months = 1 (Charter "1-month minimum")
- holding_period_pref_min_months = 6 (Charter "6-24 month preferred")

Frozen dataclass: snapshot is captured at Position open and never mutates.
LLM cannot reach in and adjust these values mid-session.
"""

from __future__ import annotations

from dataclasses import dataclass
from decimal import Decimal

__all__ = ["RiskRule", "RiskRuleInvariantError"]


class RiskRuleInvariantError(ValueError):
    """Raised when RiskRule is constructed with out-of-range or contradictory values."""


_DEFAULT_MAX_POSITION_PCT = Decimal("0.15")
_DEFAULT_MAX_SECTOR_CONCENTRATION_PCT = Decimal("0.30")
_DEFAULT_HOLDING_MIN_MONTHS = 1
_DEFAULT_HOLDING_PREF_MIN_MONTHS = 6


@dataclass(frozen=True, slots=True)
class RiskRule:
    """Immutable risk-rule snapshot."""

    max_position_pct: Decimal = _DEFAULT_MAX_POSITION_PCT
    max_sector_concentration_pct: Decimal = _DEFAULT_MAX_SECTOR_CONCENTRATION_PCT
    stop_loss_pct: Decimal | None = None
    holding_period_min_months: int = _DEFAULT_HOLDING_MIN_MONTHS
    holding_period_pref_min_months: int = _DEFAULT_HOLDING_PREF_MIN_MONTHS

    def __post_init__(self) -> None:
        for name, value in (
            ("max_position_pct", self.max_position_pct),
            ("max_sector_concentration_pct", self.max_sector_concentration_pct),
        ):
            if not isinstance(value, Decimal):
                raise RiskRuleInvariantError(
                    f"{name} must be Decimal, got {type(value).__name__}"
                )
            if not (Decimal("0") < value <= Decimal("1")):
                raise RiskRuleInvariantError(
                    f"{name} must be in (0, 1], got {value}"
                )
        if self.stop_loss_pct is not None:
            if not isinstance(self.stop_loss_pct, Decimal):
                raise RiskRuleInvariantError(
                    f"stop_loss_pct must be Decimal or None, got {type(self.stop_loss_pct).__name__}"
                )
            if not (Decimal("0") < self.stop_loss_pct <= Decimal("1")):
                raise RiskRuleInvariantError(
                    f"stop_loss_pct must be in (0, 1] or None, got {self.stop_loss_pct}"
                )
        if self.holding_period_min_months < 0:
            raise RiskRuleInvariantError(
                f"holding_period_min_months must be ≥ 0, got {self.holding_period_min_months}"
            )
        if self.holding_period_pref_min_months < self.holding_period_min_months:
            raise RiskRuleInvariantError(
                f"holding_period_pref_min_months ({self.holding_period_pref_min_months}) "
                f"< holding_period_min_months ({self.holding_period_min_months})"
            )
