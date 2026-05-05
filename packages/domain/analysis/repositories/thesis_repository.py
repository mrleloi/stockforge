"""ThesisRepository — Protocol for BC-8 Analysis thesis persistence.

Domain-layer Protocol (structural subtyping via typing.Protocol). Infrastructure
layer provides the concrete SQLiteThesisRepository implementation. The domain
never imports the infrastructure directly — this Protocol is the only interface
the use case depends on (Dependency Inversion).

Methods:
- save(thesis): persist a Thesis aggregate (upsert by thesis_id PK).
- get_by_id(thesis_id): retrieve a Thesis or None.
- find_by_ticker(ticker, as_of): find theses for a ticker at or before as_of;
  returns most-recent first.

All methods are async to support future Postgres migration (Phase 3) without
interface change.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.2.
"""

from __future__ import annotations

from datetime import date
from typing import TYPE_CHECKING, Protocol, runtime_checkable

if TYPE_CHECKING:
    from packages.contracts.types import Ticker
    from packages.domain.analysis.models.thesis import Thesis

__all__ = ["ThesisRepository"]


@runtime_checkable
class ThesisRepository(Protocol):
    """Protocol for persisting and retrieving Thesis aggregates."""

    async def save(self, thesis: Thesis) -> None:
        """Persist a Thesis. Upsert by thesis_id PK."""
        ...

    async def get_by_id(self, thesis_id: str) -> Thesis | None:
        """Retrieve a Thesis by its deterministic ID, or None if not found."""
        ...

    async def find_by_ticker(
        self, ticker: Ticker, as_of: date
    ) -> list[Thesis]:
        """Find theses for a ticker at or before as_of, most-recent first."""
        ...
