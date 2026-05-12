"""AssetSafety — operational risk tier for an editable asset.

Per spec 005 § B.1: each editable_asset declares safety = high | medium | low.
- HIGH: changes immediately affect alerts / thesis output (e.g. confluence_weights, prompts)
- MEDIUM: changes affect scoring but statistical buffer (e.g. KOL credibility formula)
- LOW: easy to revert (e.g. screening rules)

Year 2: high-safety assets require human_review_required=line_by_line (BR-9).
"""

from __future__ import annotations

from enum import Enum

__all__ = ["AssetSafety"]


class AssetSafety(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
