"""AdjustmentType + SourceProvider — Bar tagging Enums.

Per financial-data-protocol Rule 3 (Adjustment Type Tagging) + Rule 4 (Source
Attribution) + invariants I-S4 + I-S5. These tags are mandatory on every Bar
record — mixing adjusted with unadjusted in same calculation = bug class.

`str` mixin renders the lowercase token in JSON/TSV serialization, matching
the pattern established by packages/observability/state_machine.HookEventState.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["AdjustmentType", "SourceProvider"]


class AdjustmentType(StrEnum):
    """Price-adjustment lineage for a Bar OHLCV record.

    NONE     = raw historical (what was actually paid; pre-corporate-action)
    DIVIDEND = adjusted for dividends only
    SPLIT    = adjusted for stock splits only
    BOTH     = fully adjusted (typical for charts + return calculations)

    Per Rule 3: mixing AdjustmentType in same calculation raises
    MixedAdjustmentError (enforced at the service / repository layer; Phase 2).
    """

    NONE = "none"
    DIVIDEND = "dividend"
    SPLIT = "split"
    BOTH = "both"


class SourceProvider(StrEnum):
    """Data provider lineage for a Bar record. Drives reconciliation per Rule 4.

    Phase 1 thin-slice uses VNSTOCK + TCBS (S28 ingestion adapter); FIINPRO +
    SSI + WICHART deferred to Phase 2-3 per Charter § Data Sources budget tier.
    MANUAL is reserved for hand-corrected entries with override_reason.
    SCRAPED_OTHER catches any new source pre-formal-add (audit-flagged).
    """

    VNSTOCK = "vnstock"
    TCBS = "tcbs"
    FIINPRO = "fiinpro"
    SSI = "ssi"
    WICHART = "wichart"
    MANUAL = "manual"
    SCRAPED_OTHER = "scraped_other"
