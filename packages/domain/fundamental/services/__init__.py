"""BC-2 Fundamental domain services (S34 Track C).

`ratio_service` — deterministic formula library (P/E, P/B, ROE, ROA, D/E, NM).
`peer_service` — sector-based comparable ticker lookup.
`percentile_service` — historical-distribution percentile computation.

Per spec-T1-001 § B.1 "LLM Role: NONE — calculations like P/E, ROE, DCF use
deterministic formulas". I-S1 (no LLM math) and Rule 6 (provenance) are
enforced here at the entry seam.
"""

from .peer_service import PeerService
from .percentile_service import HistoricalPercentile, PercentileService
from .ratio_service import RatioComputationError, RatioInputMissingError, RatioService

__all__ = [
    "HistoricalPercentile",
    "PeerService",
    "PercentileService",
    "RatioComputationError",
    "RatioInputMissingError",
    "RatioService",
]
