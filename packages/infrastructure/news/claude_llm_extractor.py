"""ClaudeLlmExtractor — claude CLI subagent adapter implementing LlmExtractorPort.

Phase E.3 AUGMENT (plan-031 S368): ANTHROPIC SDK NO LONGER USED — default
transport is claude CLI subprocess per D-050 (ACCEPTED CHARTER 2026-05-09) +
D-051 (news-extractor refactor SHIPPED S228) + D-052 (SDK codepath removal
SHIPPED S229) + D-072 (VN claim extraction wrapper AUGMENT; this plan-031).

OPTIONAL DI (new per plan-031 DD-1 + DD-5):
- `tokenizer: TextTokenizerPort` — injected VnTokenizer adds pre-LLM hint line
  to system prompt about multi-syllable VN terms. Default = WhitespaceTokenizer
  (no hint emitted; backward-compat). Hint is OPT-IN via isinstance check.
- `lexicon: VnLexiconPort | None` — injected VnSentimentLexicon scores article
  body post-LLM. Default = None (skips lexicon scoring; backward-compat).

NEW ExtractedClaim fields (plan-031 DD-3 + DD-4; Rule 16 mode 2 by construction):
- `lexicon_score: float` — deterministic echo of VnSentimentLexicon.score().numeric_score
- `mentioned_pump_anchors: tuple[str, ...]` — deterministic frozenset intersection
  of VN_CULTURAL_ANCHORS with keyword_hits from lexicon scoring
LLM never emits these fields per updated system prompt + _build_claim design.

The adapter is fixture-friendly: tests inject a `transport` callable
(prompt: str, body: str) -> str (raw LLM JSON response) so CI never touches
the network. Default transport calls claude CLI subprocess via
`make_claude_cli_news_transport()` factory (bills against Claude Code
subscription; no ANTHROPIC_API_KEY required).

Returned JSON contract (system prompt enforces; adapter validates):
```
{
  "claims": [
    {
      "claim_text": str,
      "source_text_excerpt": str (≤500 chars verbatim quote),
      "sentiment": "strongly_bullish" | "bullish" | "neutral"
                  | "bearish" | "strongly_bearish",
      "mentioned_tickers": [str, ...],
      "mentioned_sectors": [str, ...],
      "key_phrases": [str, ...],
      "tone_indicators": [str, ...],
      "confidence": float [0, 1]
    }
  ]
}
```

NOTE: The fields `lexicon_score` and `mentioned_pump_anchors` are computed
POST-LLM by deterministic code (NOT by the LLM). They are NOT in the JSON
contract above. DO NOT include them in LLM output.

Source: financial-data-protocol.md Rule 6 + Rule 7;
specs/tier1-strategic/001-four-tier-signal-architecture.md § B.2;
.claude/skills/claude-api/SKILL.md;
plan-031 (S367 architect → S368 dev AUGMENT) D-072 PROPOSED.
"""

from __future__ import annotations

import hashlib
import json
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime

from apps._shared.entities.vn_ticker_resolver import ResolutionMethod, VnTickerResolver
from apps.extraction.sentiment.vn_lexicon import VN_CULTURAL_ANCHORS
from packages.application.nlp.ports import TextTokenizerPort, VnLexiconPort
from packages.contracts import Ticker
from packages.domain.news.models import ExtractedClaim, NewsArticle
from packages.domain.news.value_objects import ExtractorMetadata, Sentiment
from packages.infrastructure.news.claude_cli_news_transport import (
    make_claude_cli_news_transport,
)
from packages.infrastructure.nlp.vn_tokenizer import VnTokenizer, WhitespaceTokenizer

__all__ = ["ClaudeLlmExtractor"]


_DEFAULT_MODEL = "claude-sonnet-4-6"
_DEFAULT_VERSION = "stockforge-news-extractor-0.1"

# Architect default per plan-032 DD-8; mirrors _MIN_CONFIDENCE_THRESHOLD in resolver.
# E.4 resolver-injected path: only emit ticker when confidence >= this threshold.
_MIN_RESOLVER_CONFIDENCE_THRESHOLD: float = 0.85

_SYSTEM_PROMPT = """You are a Vietnamese stock-market news claim extractor.

Your job is to read one Vietnamese financial-news article and emit a JSON
object describing the structured claims it contains. You MUST follow these
rules absolutely:

RULE 1 — NO LLM MATH. Do not produce numeric scores, do not estimate price
impact, do not aggregate. Sentiment is one of five categorical labels:
strongly_bullish | bullish | neutral | bearish | strongly_bearish.

RULE 2 — GROUNDING. Every claim must include a `source_text_excerpt`: a
verbatim quote from the article body (≤500 characters) that supports the
claim. If you cannot quote the article verbatim, do NOT emit the claim.

RULE 3 — ENTITY GROUNDING. Every claim must mention at least one ticker
(uppercase 3-letter VN symbol) or sector. Claims with no entities are noise
and must be omitted.

RULE 4 — OUTPUT. Return ONLY a JSON object of the form
`{"claims": [...]}`. No prose, no markdown fences, no preamble.

NOTE: The fields `lexicon_score` and `mentioned_pump_anchors` are computed
POST-LLM by deterministic code (NOT by you). DO NOT include these in your
JSON output. Only include the 8 documented fields above.
"""

_PROMPT_HASH = hashlib.sha256(_SYSTEM_PROMPT.encode("utf-8")).hexdigest()[:16]

_VN_TOKENIZER_HINT = (
    "\n\nHINT: Vietnamese multi-syllable terms are joined with underscore "
    "in your tokenization context (e.g. 'cổ_phiếu', 'thị_trường'). "
    "When quoting `source_text_excerpt` verbatim, preserve the original "
    "Vietnamese spacing (no underscores) from the article body."
)


@dataclass
class ClaudeLlmExtractor:
    """LlmExtractorPort adapter backed by claude CLI subagent (D-050 + D-072).

    `transport`: pluggable string-in / string-out call (system prompt + body
    → raw response text). Default uses make_claude_cli_news_transport() factory
    (claude CLI subprocess; bills against Claude Code subscription). Tests
    inject a closure over recorded responses via constructor kwarg.
    `clock`: time source for ExtractorMetadata.extracted_at.
    `tokenizer`: optional TextTokenizerPort injection; if VnTokenizer, appends
    hint line to system prompt for multi-syllable VN term awareness (DD-5).
    `lexicon`: optional VnLexiconPort injection; if provided, computes
    lexicon_score + mentioned_pump_anchors deterministically post-LLM (DD-4).
    """

    transport: Callable[[str, str], str] = field(
        default_factory=make_claude_cli_news_transport
    )
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )
    model: str = _DEFAULT_MODEL
    version: str = _DEFAULT_VERSION
    system_prompt: str = _SYSTEM_PROMPT
    tokenizer: TextTokenizerPort = field(default_factory=WhitespaceTokenizer)
    lexicon: VnLexiconPort | None = None
    ticker_resolver: VnTickerResolver | None = None
    """Optional VN ticker resolver injection per plan-032 DD-5.

    Default None: backward-compat 2-4 char uppercase filter preserved (pre-E.4 behavior).
    Resolver-injected: routes each mentioned_tickers entry through VnTickerResolver.resolve();
    emits canonical Ticker only when resolution_method not UNKNOWN/AMBIGUOUS and
    resolution_confidence >= _MIN_RESOLVER_CONFIDENCE_THRESHOLD (0.85).
    Production wiring (ClaudeLlmExtractor(ticker_resolver=VnTickerResolver())) is a
    separate decision per plan-032 AQ-8; CLI default remains no-arg for v0.
    """

    def extract(self, article: NewsArticle) -> list[ExtractedClaim]:
        body = self._build_user_message(article)
        effective_prompt = self._build_effective_system_prompt()
        try:
            raw = self.transport(effective_prompt, body)
        except Exception:
            return []
        try:
            payload = json.loads(raw)
        except json.JSONDecodeError:
            return []
        if not isinstance(payload, dict):
            return []
        raw_claims = payload.get("claims")
        if not isinstance(raw_claims, list):
            return []
        prompt_hash = hashlib.sha256(
            effective_prompt.encode("utf-8")
        ).hexdigest()[:16]
        extracted_at = self.clock()
        # NEW per plan-031 DD-4: compute lexicon artifacts ONCE per article
        # (cached across all claims from same article for determinism + perf)
        lexicon_artifacts = self._compute_lexicon_artifacts(article)
        out: list[ExtractedClaim] = []
        for ordinal, raw_claim in enumerate(raw_claims):
            claim = self._build_claim(
                raw_claim,
                article=article,
                ordinal=ordinal,
                extracted_at=extracted_at,
                prompt_hash=prompt_hash,
                lexicon_artifacts=lexicon_artifacts,
            )
            if claim is not None:
                out.append(claim)
        return out

    def _build_effective_system_prompt(self) -> str:
        """Append VN-tokenization hint to system prompt if VnTokenizer injected.

        Hint is OPT-IN: only emitted when non-fallback tokenizer (VnTokenizer)
        is injected. Default WhitespaceTokenizer produces no hint — backward-compat.
        LLM still reads original Vietnamese body_excerpt (NOT tokenized input).
        Per plan-031 DD-5.
        """
        if isinstance(self.tokenizer, VnTokenizer):
            return self.system_prompt + _VN_TOKENIZER_HINT
        return self.system_prompt

    def _compute_lexicon_artifacts(
        self, article: NewsArticle
    ) -> tuple[float, tuple[str, ...]]:
        """Deterministic post-LLM lexicon scoring per Rule 16 mode 2.

        Returns (lexicon_score, mentioned_pump_anchors). NO LLM in this path.
        I-S1 compliance: pure-function; VnSentimentLexicon.score() is deterministic.
        Rule 16 mode 2: lexicon_score is deterministic echo of numeric_score.
        mentioned_pump_anchors: sorted frozenset intersection for determinism.
        Per plan-031 DD-4.
        """
        if self.lexicon is None:
            return 0.0, ()
        score = self.lexicon.score(article.body_excerpt)
        lexicon_score = score.numeric_score
        mentioned_anchors = tuple(
            sorted(VN_CULTURAL_ANCHORS & set(score.keyword_hits))
        )
        return lexicon_score, mentioned_anchors

    def _build_user_message(self, article: NewsArticle) -> str:
        return (
            f"URL: {article.source_url}\n"
            f"TITLE: {article.title}\n\n"
            f"BODY:\n{article.body_excerpt}"
        )

    def _build_claim(
        self,
        raw: object,
        *,
        article: NewsArticle,
        ordinal: int,
        extracted_at: datetime,
        prompt_hash: str,
        lexicon_artifacts: tuple[float, tuple[str, ...]],
    ) -> ExtractedClaim | None:
        if not isinstance(raw, dict):
            return None
        try:
            claim_text = str(raw["claim_text"])
            excerpt = str(raw["source_text_excerpt"])
            sentiment = Sentiment(str(raw["sentiment"]))
            confidence = float(raw.get("confidence", 0.5))
        except (KeyError, ValueError):
            return None
        raw_tickers = raw.get("mentioned_tickers", [])
        if self.ticker_resolver is None:
            # Backward-compat default: 2-4 char uppercase filter (pre-E.4 behavior).
            # Preserves 1086/1086 baseline test pass rate when resolver not injected.
            tickers = tuple(
                Ticker(str(t)) for t in raw_tickers
                if isinstance(t, str) and t.isupper() and 2 <= len(t) <= 4
            )
        else:
            # E.4 resolver-injected path per plan-032 DD-5.
            # Emits canonical Ticker only for EXACT/CASE_INSENSITIVE/DIACRITICS_STRIPPED/FUZZY
            # resolutions above confidence threshold; AMBIGUOUS + UNKNOWN are silently skipped.
            resolved: list[Ticker] = []
            for t in raw_tickers:
                if not isinstance(t, str):
                    continue
                result = self.ticker_resolver.resolve(t)
                if (
                    result.canonical_ticker is not None
                    and result.resolution_method != ResolutionMethod.UNKNOWN
                    and result.resolution_method != ResolutionMethod.AMBIGUOUS
                    and result.resolution_confidence >= _MIN_RESOLVER_CONFIDENCE_THRESHOLD
                ):
                    resolved.append(result.canonical_ticker)
            tickers = tuple(resolved)
        sectors = tuple(
            str(s) for s in raw.get("mentioned_sectors", [])
            if isinstance(s, str)
        )
        if not tickers and not sectors:
            return None
        key_phrases = tuple(
            str(p) for p in raw.get("key_phrases", [])
            if isinstance(p, str)
        )
        tone_indicators = tuple(
            str(t) for t in raw.get("tone_indicators", [])
            if isinstance(t, str)
        )
        meta = ExtractorMetadata(
            extractor_model=self.model,
            extractor_version=self.version,
            extractor_prompt_hash=prompt_hash,
            extracted_at=extracted_at,
            confidence_extracted=max(0.0, min(1.0, confidence)),
            verified_by_human=False,
        )
        lexicon_score, mentioned_pump_anchors = lexicon_artifacts
        try:
            return ExtractedClaim(
                claim_id=f"{article.article_id}:{ordinal}",
                article_id=article.article_id,
                source_url=article.source_url,
                source_text_excerpt=excerpt[:500],
                claim_text=claim_text,
                sentiment=sentiment,
                extractor=meta,
                mentioned_tickers=tickers,
                mentioned_sectors=sectors,
                key_phrases=key_phrases,
                tone_indicators=tone_indicators,
                lexicon_score=lexicon_score,
                mentioned_pump_anchors=mentioned_pump_anchors,
            )
        except ValueError:
            return None

    @property
    def prompt_hash(self) -> str:
        """Exposed for callers that want to log the prompt hash without
        triggering an extraction (e.g. CLI startup banner).
        """
        return _PROMPT_HASH
