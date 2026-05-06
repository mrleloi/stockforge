"""CoordinatedPostingDetected — cross-BC event for crowd coordination signal (BC-7).

BR-10 CONSTITUTIONAL ENFORCEMENT:
  This event MUST NOT include: poster_id, account_name, individual post content,
  operator names, or any PII. Schema is validated by pytest BR-10 test.

  Payload contains ONLY aggregate pattern description + score.
  Framing: "pattern detected, exercise caution" — NOT "pump confirmed" or operator naming.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.2.
ADR: D-032 § (h) coordination detection + BR-10 payload schema enforcement.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

__all__ = ["CoordinatedPostingDetected"]


@dataclass(frozen=True)
class CoordinatedPostingDetected:
    """Event emitted when coordination_score >= 0.8 (BR-8 threshold).

    BR-10 schema contract — FORBIDDEN fields (verified by test_coordination_detector.py):
    - NO poster_id
    - NO account_name
    - NO operator_name
    - NO individual_post_content
    - NO usernames or handles

    Permitted fields (aggregate pattern description only):
    - ticker: which ticker the pattern was detected for
    - posting_pattern: aggregate description (e.g., "10 posts cosine-sim >0.9 within 1h")
    - coordination_score: float in [0, 1]
    - detected_at: UTC timestamp
    """

    ticker: str
    posting_pattern: str    # aggregate pattern only — never names individuals
    coordination_score: float
    detected_at: datetime
