"""PumpPhase — 5-state StrEnum for pump lifecycle detection.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1 + B.3 UC-3.
ADR: D-032 § (f) deterministic 5-state weighted scoring.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["PumpPhase"]


class PumpPhase(StrEnum):
    """Phase of a suspected pump-and-dump pattern.

    Detection uses deterministic multi-signal weighted scoring (D-032 F1).
    Confidence gate ≥0.4 required before emitting a non-UNCERTAIN phase.
    """

    PRE_PUMP = "pre_pump"          # low-volume accumulation, KOL whispers
    PUMP = "pump"                  # volume + price spike, narrative seeding
    DISTRIBUTION = "distribution"  # high volume flat price, novice posts dominant
    DUMP = "dump"                  # price crash, narrative shift to confused
    UNCERTAIN = "uncertain"        # confidence below threshold; no classification
