"""BC-8 Analysis — application layer barrel export.

Contains ports (LLMPerspectivePort, CostTrackerPort), services
(recommendation_heuristic), and use cases (ValidateThesisPhase1UseCase).

Application layer depends on domain layer only via explicit import.
Infrastructure adapters inject through ports.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.3-B.4.
"""

from __future__ import annotations

from .ports import Budget, CostBudgetExceeded, CostTrackerPort, LLMPerspectivePort
from .services import confidence_from_synthesis, recommendation_from_synthesis
from .use_cases import ValidateThesisPhase1UseCase

__all__ = [
    "Budget",
    "CostBudgetExceeded",
    "CostTrackerPort",
    "LLMPerspectivePort",
    "ValidateThesisPhase1UseCase",
    "confidence_from_synthesis",
    "recommendation_from_synthesis",
]
