"""Sentiment — categorical 5-level enum for BC-7 crowd sentiment classification.

BR-4: Sentiment is ALWAYS categorical. LLM NEVER outputs numeric sentiment score.
I-S1: NO LLM math — numeric "80%" from LLM raises LlmOutputViolatesISOne.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1 + A.3 BR-4.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § c).
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["Sentiment"]


class Sentiment(StrEnum):
    """Categorical sentiment levels. NEVER numeric per BR-4 + I-S1.

    5 levels chosen to capture meaningful gradations in Vietnamese retail discourse:
    - STRONGLY_BULLISH: explicit buy/pump language ("tăng mạnh", "mua ngay")
    - BULLISH: positive outlook ("tiềm năng", "cổ phiếu tốt")
    - NEUTRAL: informational, mixed, or no directional bias
    - BEARISH: cautious/negative ("cẩn thận", "rủi ro cao")
    - STRONGLY_BEARISH: explicit sell/dump language ("bán ngay", "tháo hàng")
    """

    STRONGLY_BULLISH = "strongly_bullish"
    BULLISH = "bullish"
    NEUTRAL = "neutral"
    BEARISH = "bearish"
    STRONGLY_BEARISH = "strongly_bearish"
