"""BC-2 Fundamental infrastructure (S34 Track C).

Phase 2 wiring: vnstock Finance API adapter + SQLite repository.
G.3 (plan-043) adds ClaudeVisionPdfTableExtractor for PDF annual-report extraction.
Postgres+TimescaleDB substrate deferred to Phase 3 per architecture.md
§ Storage; SQLite proves the FundamentalRepository contract on the VN30
universe before scaling to TimescaleDB hypertables.
"""

from .claude_vision_pdf_adapter import ClaudeVisionPdfTableExtractor
from .sqlite_fundamental_repository import SqliteFundamentalRepository
from .vnstock_fundamental_adapter import (
    VnstockFundamentalAdapter,
    VnstockFundamentalAdapterError,
)

__all__ = [
    "ClaudeVisionPdfTableExtractor",
    "SqliteFundamentalRepository",
    "VnstockFundamentalAdapter",
    "VnstockFundamentalAdapterError",
]
