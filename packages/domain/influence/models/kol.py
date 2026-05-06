"""Kol — BC-6 KOL aggregate root.

A KOL (Key Opinion Leader) represents a tracked financial influencer.
The aggregate enforces:
- BR-2: status PROVISIONAL until 10 evaluated recommendations;
  `transition_to_active` enforces this gate.
- Style classification per BR-8.
- Credibility attached only when status=ACTIVE.

`transition_to_active` raises InvariantViolation if called on non-PROVISIONAL
status or if n_evaluated < 10 per BR-2.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § A.3 BR-2 + BR-8.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § c).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime

from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.kol_status import KolStatus
from packages.domain.influence.value_objects.kol_style import KolStyle

__all__ = ["InvariantViolation", "Kol"]

_PROVISIONAL_TO_ACTIVE_THRESHOLD = 10


class InvariantViolation(ValueError):
    """Raised when a domain invariant is violated on a Kol aggregate."""


@dataclass
class Kol:
    """KOL aggregate root.

    `primary_channel_id` is the main monitored channel.
    `secondary_channel_ids` holds additional channels (e.g. KOL active on
    both YouTube and Telegram).
    `credibility` is None during PROVISIONAL status and attached by
    `transition_to_active()` once ≥10 outcome reviews are evaluated (BR-2).
    `sectors_covered` is a list of VN sector codes (e.g. "banking", "realestate").
    `profile_summary` is optional free-text description.
    `last_active_at` is updated by the scraper on each ingestion run.

    I-S35: KOLs are tracked as research subjects, not financial advisors.
    """

    kol_id: KolId
    name: str
    primary_channel_id: ChannelId
    style: KolStyle
    status: KolStatus
    sectors_covered: list[str] = field(default_factory=list)
    secondary_channel_ids: list[ChannelId] = field(default_factory=list)
    profile_summary: str | None = None
    last_active_at: datetime | None = None
    created_at: datetime | None = None

    def __post_init__(self) -> None:
        if not self.name or not self.name.strip():
            raise InvariantViolation("Kol.name must be a non-empty string")

    def transition_to_active(self, n_evaluated: int) -> None:
        """Promote PROVISIONAL KOL to ACTIVE when ≥10 recommendations evaluated (BR-2).

        Raises InvariantViolation if:
        - Current status is not PROVISIONAL.
        - n_evaluated is below the threshold (10).
        """
        if self.status != KolStatus.PROVISIONAL:
            raise InvariantViolation(
                f"transition_to_active requires PROVISIONAL status; "
                f"current status is {self.status!r}"
            )
        if n_evaluated < _PROVISIONAL_TO_ACTIVE_THRESHOLD:
            raise InvariantViolation(
                f"BR-2: KOL requires ≥{_PROVISIONAL_TO_ACTIVE_THRESHOLD} evaluated "
                f"recommendations to become ACTIVE; got {n_evaluated}"
            )
        self.status = KolStatus.ACTIVE

    @property
    def is_provisional(self) -> bool:
        return self.status == KolStatus.PROVISIONAL

    @property
    def is_active(self) -> bool:
        return self.status == KolStatus.ACTIVE
