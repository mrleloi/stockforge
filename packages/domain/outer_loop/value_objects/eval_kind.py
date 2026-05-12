"""EvalKind — class of eval-set item (BR-10 minimum-set checking + activation gate).

Per spec 005 § A.2: outer loop activation gated on minimum eval-set sizes per kind:
- THESIS: ≥100 completed thesis outcomes
- KOL_RECOMMENDATION: ≥500 KOL rec outcomes
- PUMP: ≥20 labeled historical pumps
- NARRATIVE: ≥10 narratives through full lifecycle

Year2ActivationGate consumes per-kind counts and decides READY vs NOT_READY.
"""

from __future__ import annotations

from enum import Enum

__all__ = ["EvalKind"]


class EvalKind(str, Enum):
    THESIS = "thesis"
    KOL_RECOMMENDATION = "kol_recommendation"
    PUMP = "pump"
    NARRATIVE = "narrative"
