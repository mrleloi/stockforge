"""SignalContribution — value object recording a single signal's contribution to pump scoring (BC-7).

Invariants (D-032 § c):
- signal_name must not be empty
- weight in [0, 1]
- contribution in [0, 1]

I-10: ZERO framework dependencies (pure stdlib).
I-S1: all numeric fields are Python-computed; never LLM output.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-3.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § f).
"""

from __future__ import annotations

from dataclasses import dataclass

from packages.domain.crowd.value_objects.pump_phase import PumpPhase

__all__ = ["SignalContribution"]


@dataclass(frozen=True)
class SignalContribution:
    """Records the contribution of a single signal to pump phase classification.

    Audit trail: persisted alongside PumpDetection for explainability.
    I-S1: all numeric fields computed from deterministic Python; never from LLM.
    """

    signal_name: str           # e.g. "volume_price_spike", "fomo_active"
    signal_value: float        # normalized signal value [0, 1]
    weight: float              # configured weight for this signal [0, 1]
    contribution: float        # weight * signal_value [0, 1]
    phase: PumpPhase           # which phase this signal supports

    def __post_init__(self) -> None:
        if not self.signal_name:
            raise ValueError("SignalContribution.signal_name must not be empty")
        if not (0.0 <= self.weight <= 1.0):
            raise ValueError(
                f"SignalContribution.weight must be in [0, 1]; got {self.weight!r}"
            )
        if not (0.0 <= self.contribution <= 1.0):
            raise ValueError(
                f"SignalContribution.contribution must be in [0, 1]; got {self.contribution!r}"
            )
