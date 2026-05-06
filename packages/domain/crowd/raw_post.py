"""RawPost — value object for a single forum/group/comment post before classification.

BR-3: Individual posts are retained for debugging sample only (max 20 per snapshot).
     Aggregate metrics are retained permanently.
BR-1: Raw posts must only ever come from public sources; is_public() pre-flight at adapter.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1 + B.4.
ADR: D-032 § (b) adapter pattern + (c) domain aggregates.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

__all__ = ["RawPost"]


@dataclass(frozen=True)
class RawPost:
    """A single unclassified post fetched from a public crowd source.

    Fields:
        post_id:          Platform-specific ID (e.g., "f319_123456_789").
        ticker:           VN ticker this post was retrieved for (e.g., "VND").
        source:           Platform name: "f319" | "fb_group" | "cafef_comments" |
                          "vietstock_comments".
        source_url:       Canonical URL to the post. Required for I-S2 provenance.
        posted_at:        UTC datetime when the post was published.
        text:             Raw post text (Vietnamese).
        poster_id:        Opaque platform user ID. NEVER surfaced in CoordinationDetected
                          payload per BR-10.
        account_age_days: Days since account creation, or None if unavailable.
    """

    post_id: str
    ticker: str
    source: str
    source_url: str
    posted_at: datetime
    text: str
    poster_id: str
    account_age_days: int | None = None
