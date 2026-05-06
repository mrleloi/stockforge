"""KolRepositoryPort — application Protocol for KOL persistence.

Application layer Protocol; concrete implementations live in
packages/infrastructure/influence/sqlite_kol_repository.py.
"""

from __future__ import annotations

from typing import Protocol

from packages.domain.influence.models.kol import Kol
from packages.domain.influence.value_objects.kol_id import KolId

__all__ = ["KolRepositoryPort"]


class KolRepositoryPort(Protocol):
    """Persistence boundary for the Kol aggregate."""

    async def get(self, kol_id: KolId) -> Kol | None:
        """Load a Kol by id, or None if absent."""
        ...

    async def save(self, kol: Kol) -> None:
        """Insert or update a Kol (upsert semantics)."""
        ...

    async def list_all(self) -> list[Kol]:
        """Return every persisted Kol (small N expected during Phase 3)."""
        ...
