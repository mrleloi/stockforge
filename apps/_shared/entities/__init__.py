"""apps/_shared/entities — cross-app shared entity-resolution utilities.

Exports VnTickerResolver + ResolutionResult + ResolutionMethod for downstream
consumers. Per plan-032 DD-1 (FRESH MODULE + ALIAS TABLE strategy) + ADR D-073.
"""

from apps._shared.entities.vn_ticker_resolver import (
    ResolutionMethod,
    ResolutionResult,
    VnTickerResolver,
)

__all__ = ["ResolutionMethod", "ResolutionResult", "VnTickerResolver"]
