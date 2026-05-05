"""PeerService — sector-based VN30 comparable ticker lookup (S34 Track C).

Phase 2 thin slice: peers come from an injected universe of constituent
records. The default factory is empty — BC-2 cannot directly import BC-1's
VN30_UNIVERSE without violating Charter "Cross-BC communication via contracts
only". Composition layer (apps/cli/ingest_fundamentals_vn30.py + thesis
pipeline) wires the live universe via `PeerService.from_constituents(...)`.

Sector lookup is current-snapshot only — point-in-time sector membership (a
ticker may have been re-classified between sectors) is a Phase 3 refinement
when financial-data-protocol Rule 2 (survivorship-aware universe) lands.
"""

from __future__ import annotations

from collections.abc import Iterable, Sequence
from dataclasses import dataclass, field
from datetime import date
from typing import Protocol, runtime_checkable

from packages.contracts import Ticker

__all__ = ["ConstituentRecord", "PeerService"]


@runtime_checkable
class ConstituentRecord(Protocol):
    """Minimal universe-record shape PeerService consumes.

    Any class with `ticker: Ticker` and `sector: str` attributes satisfies the
    contract — including BC-1's `Vn30Constituent` (frozen dataclass with those
    fields). Phase 2 keeps the protocol narrow; Phase 3 may add `listing_date`
    when Rule 2 survivorship logic lands.
    """

    @property
    def ticker(self) -> Ticker: ...
    @property
    def sector(self) -> str: ...


@dataclass
class PeerService:
    """Look up sector peers from an injected universe.

    The composition layer (apps/cli/* + Phase1DataGatherer wiring) constructs
    PeerService with the live VN30 constituents — domain stays cross-BC
    clean (no `from packages.domain.market_data...` import here).
    """

    universe: Sequence[ConstituentRecord] = field(default_factory=tuple)
    min_peers: int = 3
    max_peers: int = 5

    def get_comparables(
        self,
        ticker: Ticker,
        sector_as_of: date,
    ) -> tuple[Ticker, ...]:
        """Return up to `max_peers` same-sector tickers, excluding `ticker`.

        Sector for `ticker` resolves from the injected universe; if `ticker`
        is not present, returns empty tuple. `sector_as_of` is reserved for
        Phase 3 point-in-time sector lookup — Phase 2 uses live constituents
        regardless.
        """
        _ = sector_as_of  # Phase 3 will wire this; documented forward-compat
        anchor = self._lookup(ticker)
        if anchor is None:
            return ()
        candidates = [
            c.ticker for c in self.universe
            if c.sector == anchor.sector and c.ticker != ticker
        ]
        if len(candidates) < self.min_peers:
            # Sector too thin within the injected universe — Phase 3 broadens
            # to HOSE-listed peers outside VN30. Phase 2 returns whatever is
            # available so the thesis pipeline proceeds with degraded
            # peer-comparable confidence rather than failing closed.
            return tuple(candidates)
        return tuple(candidates[: self.max_peers])

    def get_sector(self, ticker: Ticker) -> str | None:
        """Return the sector string for `ticker`, or None if not in universe.
        Used by the data-gatherer to populate FinancialStatement.sector when
        the adapter cannot derive it from vendor payload.
        """
        constituent = self._lookup(ticker)
        return constituent.sector if constituent is not None else None

    def _lookup(self, ticker: Ticker) -> ConstituentRecord | None:
        for c in self.universe:
            if c.ticker == ticker:
                return c
        return None

    def all_sectors(self) -> Iterable[str]:
        """Distinct sector strings across the universe (sorted, deterministic)."""
        return sorted({c.sector for c in self.universe})

    @classmethod
    def from_constituents(
        cls,
        constituents: Sequence[ConstituentRecord],
        *,
        min_peers: int = 3,
        max_peers: int = 5,
    ) -> PeerService:
        """Convenience constructor for the composition layer."""
        return cls(universe=constituents, min_peers=min_peers, max_peers=max_peers)
