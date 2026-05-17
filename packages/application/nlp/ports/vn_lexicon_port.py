"""VnLexiconPort — abstract port for VN sentiment lexicon scoring.

Per architecture.md § Ports & Adapters + parent plan-028 DD-7: NLP is a
cross-BC capability (BC-5 News Stream + BC-6 Influence + BC-7 Crowd all
consume sentiment-scored VN text), so the port lives in application/nlp/
namespace established by sub-plan 029 D1. Concrete adapters live in
apps/extraction/sentiment/ per parent DD-8.

Source: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md
        § DD-4 (LEXICON-PATTERN-PORT + CALIBRATE) + DD-8 (apps/extraction/sentiment/);
        agent-workspace/session-plans/pending/030-S364-phase-e2-vn-sentiment-lexicon.md
        § DD-1 (Protocol vs ABC — mirrors sub-plan 029 D1 + LlmExtractorPort precedent
        at packages/application/news/ports/llm_extractor_port.py:28).

I-S1 compliance: lexicon scoring path is LLM-free by construction — no LLM SDK
imported, no anthropic/openai call in any implementation of this port.

Rule 16 mode-2 compliance: numeric_score field on SentimentScore output is
deterministic-pipeline echo from lexicon-weight summation; no LLM involvement.

D-059 compliance (ALL implementations):
- R1 (datetime-no-tz): N/A lexicon is pure text transform; no datetime.
- R2 (unseeded RNG): lexicon MUST be deterministic; no random state.
- R4 (time.time-in-domain): N/A apps-tier orchestration, not domain.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from apps.extraction.sentiment.vn_lexicon import SentimentScore  # forward-ref

__all__ = ["VnLexiconPort"]


class VnLexiconPort(Protocol):
    """Score Vietnamese text for sentiment polarity using rule-based lexicon.

    Implementations MUST:
    - Be deterministic — same input string => same SentimentScore (D-059 R2
      compliance; verifier grep-asserts determinism smoke at S366).
    - Return SentimentScore.empty() for empty / whitespace-only input (NOT raise).
    - Satisfy Rule 16 mode 2 — numeric_score computed via deterministic
      lexicon-weight summation; no LLM in scoring path.

    Implementations MAY:
    - Tokenize input via injected tokenizer (default VnTokenizer via DI).
    - Cap input text length at sensible upper bound and return empty score.
    - Cache scoring results (NOT required for v0 per DD-5 of sub-plan 030).
    """

    def score(self, text: str) -> SentimentScore:
        """Return SentimentScore for ``text`` via lexicon-weight scoring."""
        ...
