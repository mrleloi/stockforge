"""BC-2 Fundamental infrastructure (S34 Track C).

Phase 2 wiring: vnstock Finance API adapter + SQLite repository.
Postgres+TimescaleDB substrate deferred to Phase 3 per architecture.md
§ Storage; SQLite proves the FundamentalRepository contract on the VN30
universe before scaling to TimescaleDB hypertables.
"""

from .sqlite_fundamental_repository import SqliteFundamentalRepository
from .vnstock_fundamental_adapter import (
    VnstockFundamentalAdapter,
    VnstockFundamentalAdapterError,
)

__all__ = [
    "SqliteFundamentalRepository",
    "VnstockFundamentalAdapter",
    "VnstockFundamentalAdapterError",
]
