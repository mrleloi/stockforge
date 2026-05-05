"""BC-1 Market Data infrastructure adapters.

S28 deliverables:
- VnstockAdapter (BarProviderPort impl; vnstock library, source=VCI)
- TcbsAdapter (BarProviderPort impl; TCBS public REST API — DEAD per D-012; kept
  for archive + graceful-fail wiring)
- ReconciliationService (pure logic; per Rule 4)
- SqliteBarRepository (BarRepository impl; local SQLite for Phase 1 thin-slice)

S32 deliverable (D-012; Track A R2 closure):
- SsiAdapter (BarProviderPort impl; SSI iBoard public chart API — primary
  alternate to VnstockAdapter for Rule 4 multi-source reconciliation)

Postgres + TimescaleDB-backed BarRepository deferred to Phase 2 per spec 000.
"""

from packages.infrastructure.market_data.reconciliation_service import (
    ReconciledBar,
    ReconciliationConfidence,
    ReconciliationService,
)
from packages.infrastructure.market_data.sqlite_bar_repository import SqliteBarRepository
from packages.infrastructure.market_data.ssi_adapter import SsiAdapter, SsiApiError
from packages.infrastructure.market_data.tcbs_adapter import TcbsAdapter, TcbsApiError
from packages.infrastructure.market_data.vnstock_adapter import VnstockAdapter, VnstockAdapterError

__all__ = [
    "ReconciledBar",
    "ReconciliationConfidence",
    "ReconciliationService",
    "SqliteBarRepository",
    "SsiAdapter",
    "SsiApiError",
    "TcbsAdapter",
    "TcbsApiError",
    "VnstockAdapter",
    "VnstockAdapterError",
]
