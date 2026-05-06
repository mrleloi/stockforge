"""BC-6 Influence Network — domain services barrel.

Domain services hold deterministic logic that doesn't naturally belong on a
single aggregate. Per I-S1 these services NEVER invoke an LLM — credibility
math is pure code with traceable inputs.
"""

from .calibration_service import CalibrationResult, CalibrationService
from .outcome_evaluator import EXCESS_RETURN_THRESHOLDS, OutcomeEvaluator

__all__ = [
    "CalibrationService",
    "CalibrationResult",
    "EXCESS_RETURN_THRESHOLDS",
    "OutcomeEvaluator",
]
