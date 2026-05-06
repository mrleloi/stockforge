"""NarrativePhase — 7-state StrEnum for narrative lifecycle.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1.
ADR: D-032 § (e) deterministic 7-state machine.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["NarrativePhase"]


class NarrativePhase(StrEnum):
    """Lifecycle phase of a market narrative in Vietnamese retail community.

    Phase order (BR-7): INCUBATION → EMERGING → MAINSTREAM → SATURATION →
    EXHAUSTION → REVERSAL → DEAD. Phases do not skip forward more than 2 steps
    in a single classification cycle (hysteresis applied in classifier config).
    """

    INCUBATION = "incubation"    # first mentions, few; avg_mentions_per_day < 5
    EMERGING = "emerging"        # velocity rising, not mainstream yet
    MAINSTREAM = "mainstream"    # major KOLs + news covering
    SATURATION = "saturation"    # everyone knows, no new bulls to convert
    EXHAUSTION = "exhaustion"    # velocity declining despite mentions
    REVERSAL = "reversal"        # counter-narrative emerging
    DEAD = "dead"                # no more mentions
