"""VN30 universe — frozen list of 30 HOSE VN30 index constituents.

Source: HOSE VN30 index composition as-of 2026-04-30, cross-checked against
SSI iBoard chart-history endpoint coverage probe (`data/vn30-probe-ssi.json`,
S32 D-012). All 30 constituents probed 248 trading-day rows for window
2025-04-30 → 2026-04-29; SSI coverage = 30/30 = 100%.

Per amendment-VN Rule 14 (PROPOSAL — not yet promoted to constitution): every
VN30 entry is HOSE-listed, so reconciliation tolerance defaults to ±1%
(`ReconciliationService._DEFAULT_TOLERANCE`). When amendment-VN promotes,
the `sàn` field on each constituent will key per-Sàn dispatch in
`ReconciliationService.tolerance_for(bar)`. For Phase 2 / S33: HOSE-only
locks the tolerance to ±1% across the entire universe.

Sector classification follows HOSE industry codes; vốn_hóa values are
informational point-in-time snapshots (trillion VND, as-of 2026-04-30) and
are NOT used for reconciliation logic — they exist for downstream analytics
that need a market-cap weighting reference. Re-validate quarterly per
HOSE re-balancing cadence.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from decimal import Decimal

from packages.contracts import Ticker

__all__ = ["Vn30Constituent", "VN30_UNIVERSE", "vn30_tickers"]


@dataclass(frozen=True, slots=True)
class Vn30Constituent:
    """Immutable VN30 index constituent metadata.

    `sàn` is locked to "HOSE" for VN30 by index construction (HOSE-only
    composite); the field exists so amendment-VN Rule 14 per-Sàn dispatch
    extends naturally to non-VN30 tickers when Track C+ broadens scope.
    """

    ticker: Ticker
    sàn: str
    sector: str
    listing_date: date
    market_cap_tn_vnd: Decimal


def _t(symbol: str) -> Ticker:
    return Ticker(symbol)


VN30_UNIVERSE: tuple[Vn30Constituent, ...] = (
    Vn30Constituent(_t("ACB"), "HOSE", "Banking",      date(2020, 12,  9), Decimal("110.0")),
    Vn30Constituent(_t("BCM"), "HOSE", "Real Estate",  date(2020,  9,  9), Decimal( "62.0")),
    Vn30Constituent(_t("BID"), "HOSE", "Banking",      date(2014,  1, 24), Decimal("260.0")),
    Vn30Constituent(_t("BVH"), "HOSE", "Insurance",    date(2009,  6, 25), Decimal( "35.0")),
    Vn30Constituent(_t("CTG"), "HOSE", "Banking",      date(2009,  7, 16), Decimal("180.0")),
    Vn30Constituent(_t("FPT"), "HOSE", "Technology",   date(2006, 12, 13), Decimal("210.0")),
    Vn30Constituent(_t("GAS"), "HOSE", "Energy",       date(2012,  5, 21), Decimal("180.0")),
    Vn30Constituent(_t("GVR"), "HOSE", "Materials",    date(2018,  3, 21), Decimal( "80.0")),
    Vn30Constituent(_t("HDB"), "HOSE", "Banking",      date(2018,  1,  5), Decimal( "73.0")),
    Vn30Constituent(_t("HPG"), "HOSE", "Materials",    date(2007, 11, 15), Decimal("160.0")),
    Vn30Constituent(_t("MBB"), "HOSE", "Banking",      date(2011, 11,  1), Decimal("130.0")),
    Vn30Constituent(_t("MSN"), "HOSE", "Consumer",     date(2009, 11,  5), Decimal( "98.0")),
    Vn30Constituent(_t("MWG"), "HOSE", "Retail",       date(2014,  7, 14), Decimal( "85.0")),
    Vn30Constituent(_t("PLX"), "HOSE", "Energy",       date(2017,  4, 21), Decimal( "55.0")),
    Vn30Constituent(_t("POW"), "HOSE", "Utilities",    date(2019,  1, 14), Decimal( "31.0")),
    Vn30Constituent(_t("SAB"), "HOSE", "Consumer",     date(2016, 12,  6), Decimal( "70.0")),
    Vn30Constituent(_t("SHB"), "HOSE", "Banking",      date(2020, 11, 11), Decimal( "50.0")),
    Vn30Constituent(_t("SSB"), "HOSE", "Banking",      date(2021,  3, 24), Decimal( "60.0")),
    Vn30Constituent(_t("SSI"), "HOSE", "Financials",   date(2007, 10, 29), Decimal( "57.0")),
    Vn30Constituent(_t("STB"), "HOSE", "Banking",      date(2006,  7, 12), Decimal( "70.0")),
    Vn30Constituent(_t("TCB"), "HOSE", "Banking",      date(2018,  6,  4), Decimal("160.0")),
    Vn30Constituent(_t("TPB"), "HOSE", "Banking",      date(2018,  4, 19), Decimal( "45.0")),
    Vn30Constituent(_t("VCB"), "HOSE", "Banking",      date(2009,  6, 30), Decimal("510.0")),
    Vn30Constituent(_t("VHM"), "HOSE", "Real Estate",  date(2018,  5, 17), Decimal("200.0")),
    Vn30Constituent(_t("VIB"), "HOSE", "Banking",      date(2020, 11, 10), Decimal( "55.0")),
    Vn30Constituent(_t("VIC"), "HOSE", "Real Estate",  date(2007,  9, 19), Decimal("170.0")),
    Vn30Constituent(_t("VJC"), "HOSE", "Industrials",  date(2017,  2, 28), Decimal( "62.0")),
    Vn30Constituent(_t("VNM"), "HOSE", "Consumer",     date(2006,  1, 19), Decimal("140.0")),
    Vn30Constituent(_t("VPB"), "HOSE", "Banking",      date(2017,  8, 17), Decimal("145.0")),
    Vn30Constituent(_t("VRE"), "HOSE", "Real Estate",  date(2017, 11,  6), Decimal( "57.0")),
)


def vn30_tickers() -> tuple[Ticker, ...]:
    """Return the 30 VN30 Tickers in canonical alphabetical order."""
    return tuple(c.ticker for c in VN30_UNIVERSE)


assert len(VN30_UNIVERSE) == 30, f"VN30 must have exactly 30 constituents, got {len(VN30_UNIVERSE)}"
assert len({c.ticker.symbol for c in VN30_UNIVERSE}) == 30, "VN30 tickers must be unique"
assert all(c.sàn == "HOSE" for c in VN30_UNIVERSE), "VN30 is HOSE-only by index construction"
