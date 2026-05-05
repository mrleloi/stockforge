"""BC-9 Portfolio & Action — watchlist, positions, risk, alerts, personal bias.

Phase 1 thin-slice (S27): RiskRule value object + Position entity.
Watchlist + Alert + PersonalBias + Decision aggregates per architecture.md
§ BC-9 deferred to Phase 2.

Cross-BC reference: Position.compute_value() emits PositionValueComputed
(packages/contracts/events/) — a downstream BC-8 (Analysis) can consume the
event for thesis valuation without taking a domain dependency on Portfolio.
"""

from .models import Position, PositionInvariantError
from .value_objects import RiskRule, RiskRuleInvariantError

__all__ = [
    "Position",
    "PositionInvariantError",
    "RiskRule",
    "RiskRuleInvariantError",
]
