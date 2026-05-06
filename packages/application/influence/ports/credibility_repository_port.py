"""CredibilityRepositoryPort — application Protocol for CredibilityScore persistence."""

from __future__ import annotations

from typing import Protocol

from packages.domain.influence.models.credibility_score import CredibilityScore
from packages.domain.influence.value_objects.kol_id import KolId

__all__ = ["CredibilityRepositoryPort"]


class CredibilityRepositoryPort(Protocol):
    """Persistence boundary for the CredibilityScore aggregate."""

    async def get(self, kol_id: KolId) -> CredibilityScore | None:
        """Load the latest CredibilityScore for a KOL, or None if absent."""
        ...

    async def save(self, score: CredibilityScore) -> None:
        """Upsert the CredibilityScore (kol_id PK)."""
        ...
