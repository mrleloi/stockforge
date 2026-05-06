"""LlmSentimentClassifier — Vietnamese categorical sentiment classifier.

D-026 LLM Substrate Boundary patterns (MANDATORY citation per D-032 § d):

Pattern BP-S43b-1 — Per-role override dict:
    `role_model_overrides` allows per-site switching:
    - Default: claude-haiku-3-5 (cost-driven batch; ~50 posts/call)
    - Override to claude-sonnet-4-6 for high-stakes re-classification
    - Override to claude-opus-4 for rare quality checks

Pattern BP-S43b-2 — Prose-tolerant JSON:
    3-tier extractor: fenced block → first-`{` heuristic → best-effort recovery.
    Reuses pattern from subagent_transport.py:55-118 (Phase 2 BC-8 substrate).
    Vietnamese LLM output often includes preamble before JSON block.

Pattern BP-S43b-3 — Gatherer-wired compute:
    `CrowdContentGatherer` prepares post batches + window metadata + ticker context.
    Numbers (mention_count, posting_velocity, coordination_scores) come from Python code.
    LLM ONLY outputs: list[str] of Sentiment enum values.

BR-4 + I-S1 enforcement:
    LLM output MUST be one of the 5 Sentiment enum values.
    Any numeric string in output raises LlmOutputViolatesISOne (NOT silently coerced).
    Pattern: `if re.search(r'\\d+\\s*%|approximately|roughly', output_str)` → raise.

IMPL-S66-1 — Empirical probe deferred:
    No API keys in sandbox environment. Strategy S3 (Haiku-prefilter + Sonnet-extract
    hybrid) is recommended per BC-6 S47 KOL probe precedent (Sonnet won for Vietnamese
    content quality). Actual probe DEFERRED to first dogfood week with API keys.
    Decision: implement S1 strategy (Haiku-only batch) as Phase 3 default;
    S3 hybrid can be enabled via role_model_overrides when API keys available.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.4 + B.7.
ADR: D-032 § (d) LLM substrate boundary.
Skill: .claude/skills/empirical-probe-first/SKILL.md.
"""

from __future__ import annotations

import json
import logging
import re
from collections.abc import Callable
from dataclasses import dataclass, field

from packages.application.crowd.ports.sentiment_classifier_port import (
    ClassifiedPost,
    LlmOutputViolatesISOne,
)
from packages.domain.crowd.raw_post import RawPost
from packages.domain.crowd.value_objects.sentiment import Sentiment

__all__ = ["LlmSentimentClassifier"]

logger = logging.getLogger(__name__)

# I-S1 guard: patterns that indicate LLM is outputting numeric content
_NUMERIC_LEAKAGE_PATTERN = re.compile(
    r"\d+\s*%|approximately|roughly|around\s+\d+|score\s*[:=]\s*\d"
)

_BATCH_SIZE = 50  # 50 posts per LLM call (cost-efficient per D-032 § d)

_VALID_SENTIMENTS = {s.value for s in Sentiment}

# Default model per D-026 BP-S43b-1 per-role override dict
_DEFAULT_MODEL = "claude-haiku-3-5"

_CLASSIFICATION_PROMPT_TEMPLATE = """You are a Vietnamese stock market sentiment classifier.

Classify each post's sentiment toward the stock ticker it discusses.
Output a JSON array with exactly {n} objects, one per post, in order.
Each object: {{"post_id": "<id>", "sentiment": "<level>"}}

Sentiment levels (use EXACTLY one of these values):
- strongly_bullish: very positive, strong buy language
- bullish: positive, optimistic
- neutral: informational, mixed, or no directional bias
- bearish: cautious, negative outlook
- strongly_bearish: very negative, strong sell/dump language

IMPORTANT RULES:
- Output ONLY the JSON array. No explanation, no numbers, no percentages.
- Use ONLY the exact sentiment values listed above.
- Preserve all Vietnamese diacritics in post text as-is (do not transliterate).
- If a post is irrelevant to the ticker, classify as neutral.

Posts to classify:
{posts_json}

Output (JSON array only):"""


@dataclass
class LlmSentimentClassifier:
    """LLM-based Vietnamese sentiment classifier implementing SentimentClassifierPort.

    Args:
        llm_client:           Callable(model, prompt) -> str. Inject mock in tests.
        role_model_overrides: Per-call model override dict (D-026 BP-S43b-1).
        batch_size:           Posts per LLM call (default 50).
    """

    llm_client: Callable[[str, str], str]
    role_model_overrides: dict[str, str] = field(default_factory=dict)
    batch_size: int = _BATCH_SIZE

    def _model_for_role(self, role: str) -> str:
        """BP-S43b-1: per-role model override lookup with default fallback."""
        return self.role_model_overrides.get(role, _DEFAULT_MODEL)

    def classify_batch(self, posts: list[RawPost]) -> list[ClassifiedPost]:
        """Classify a batch of posts into categorical Sentiment levels.

        BR-4: output is always Sentiment enum — never numeric.
        Raises LlmOutputViolatesISOne if LLM returns numeric content.
        Raises ValueError if posts is empty.

        Batches to self.batch_size per call.
        """
        if not posts:
            raise ValueError("classify_batch requires at least 1 post")

        results: list[ClassifiedPost] = []
        for i in range(0, len(posts), self.batch_size):
            batch = posts[i : i + self.batch_size]
            classified = self._classify_single_batch(batch)
            results.extend(classified)

        return results

    def _classify_single_batch(self, batch: list[RawPost]) -> list[ClassifiedPost]:
        """Classify one batch via LLM.

        BP-S43b-2 prose-tolerant JSON extraction:
        1. Try fenced code block (```json ... ```)
        2. Try first '[' to last ']' in response
        3. Raise on total parse failure
        """
        posts_json = json.dumps(
            [{"post_id": p.post_id, "text": p.text} for p in batch],
            ensure_ascii=False,
        )
        prompt = _CLASSIFICATION_PROMPT_TEMPLATE.format(
            n=len(batch), posts_json=posts_json
        )
        model = self._model_for_role("sentiment_classification")

        raw_response = self.llm_client(model, prompt)

        # I-S1 guard: reject numeric leakage in LLM output
        self._check_no_numeric_leakage(raw_response)

        # BP-S43b-2: prose-tolerant JSON extraction
        parsed = self._extract_json_array(raw_response)

        # Map results back to ClassifiedPost
        result_by_id: dict[str, str] = {}
        for item in parsed:
            if isinstance(item, dict):
                item_dict: dict[str, object] = item
                pid = str(item_dict.get("post_id", ""))
                sentiment_str = str(item_dict.get("sentiment", "")).lower().strip()
                result_by_id[pid] = sentiment_str

        classified: list[ClassifiedPost] = []
        for post in batch:
            sentiment_str = result_by_id.get(post.post_id, "neutral")
            sentiment = self._parse_sentiment(sentiment_str, post.post_id)
            classified.append(
                ClassifiedPost(
                    post_id=post.post_id,
                    ticker=post.ticker,
                    source=post.source,
                    source_url=post.source_url,
                    posted_at=post.posted_at,
                    text=post.text,
                    poster_id=post.poster_id,
                    account_age_days=post.account_age_days,
                    sentiment=sentiment,
                )
            )

        return classified

    @staticmethod
    def _check_no_numeric_leakage(response: str) -> None:
        """I-S1 + BR-4: raise if LLM output contains numeric sentiment content.

        Raises LlmOutputViolatesISOne for patterns like "80%", "approximately 18%",
        "score: 0.75", "around 60".
        """
        if _NUMERIC_LEAKAGE_PATTERN.search(response):
            raise LlmOutputViolatesISOne(
                f"LLM output violates I-S1 (NO LLM math): numeric content detected "
                f"in sentiment classifier response. LLM must output ONLY categorical "
                f"Sentiment enum values. Got: {response[:200]!r}"
            )

    @staticmethod
    def _extract_json_array(response: str) -> list[object]:
        """BP-S43b-2: 3-tier prose-tolerant JSON extraction."""
        # Tier 1: fenced code block
        fence_match = re.search(r"```(?:json)?\s*(\[.*?\])\s*```", response, re.DOTALL)
        if fence_match:
            try:
                result: list[object] = json.loads(fence_match.group(1))
                return result
            except json.JSONDecodeError:
                pass

        # Tier 2: first '[' to last ']'
        start = response.find("[")
        end = response.rfind("]")
        if start != -1 and end != -1 and end > start:
            try:
                result2: list[object] = json.loads(response[start : end + 1])
                return result2
            except json.JSONDecodeError:
                pass

        # Tier 3: best-effort recovery — return empty (caller handles missing IDs → neutral)
        logger.warning(
            "LlmSentimentClassifier: JSON extraction failed; defaulting batch to neutral"
        )
        return []

    @staticmethod
    def _parse_sentiment(value: str, post_id: str) -> Sentiment:
        """Parse LLM string output to Sentiment enum.

        Falls back to NEUTRAL on unrecognized value (logs warning).
        """
        if value in _VALID_SENTIMENTS:
            return Sentiment(value)
        logger.warning(
            "LlmSentimentClassifier: unrecognized sentiment %r for post %s; "
            "defaulting to NEUTRAL",
            value,
            post_id,
        )
        return Sentiment.NEUTRAL
