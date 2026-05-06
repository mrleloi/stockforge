"""PumpAction — 4-level recommended action StrEnum for pump detections.

I-S35: framing as research aid. Output is "consideration" not "recommendation".
Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1.
ADR: D-032 § (c) domain aggregate invariants.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["PumpAction"]


class PumpAction(StrEnum):
    """Research-aid framing per I-S35. NOT financial advice.

    AVOID: strong pump signals — consider avoiding new positions (research context)
    EXIT_IF_HOLDING: distribution/dump signals — review existing positions
    WATCH: pre-pump or ambiguous signals — monitor closely
    INFORMATIONAL: low-confidence or UNCERTAIN phase — situational awareness only
    """

    AVOID = "avoid"
    EXIT_IF_HOLDING = "exit_if_holding"
    WATCH = "watch"
    INFORMATIONAL = "informational"
