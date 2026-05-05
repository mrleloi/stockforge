"""Recommendation — heuristic output of Phase1Synthesizer.

Phase 1 heuristic (BR-7): never a single buy/sell scalar; always one of four
research-framing labels. THESIS_CANDIDATE is the strongest positive signal;
PASS means insufficient evidence or all-weak bear+bull.

Banned verbs per I-S35: "buy", "sell", "recommend". These enum values are
intentionally framed as research-aid language.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.2.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["Recommendation"]


class Recommendation(StrEnum):
    """Heuristic thesis recommendation (Phase 1 — research-aid framing only)."""

    THESIS_CANDIDATE = "thesis_candidate"
    INVESTIGATE = "investigate"
    WATCH = "watch"
    PASS = "pass"
