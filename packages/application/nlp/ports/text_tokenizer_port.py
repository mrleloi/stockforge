"""TextTokenizerPort — abstract port for VN text tokenization.

Per architecture.md § Ports & Adapters + parent plan-028 DD-7: NLP is a
cross-BC capability (BC-5 News Stream + BC-6 Influence + BC-7 Crowd all
consume tokenized VN text), so the port lives in application/nlp/ (NEW
namespace) accessible across BCs. Concrete adapters live in
packages/infrastructure/nlp/.

Source: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md
        § DD-7 (cross-BC NLP port location);
        agent-workspace/session-plans/pending/029-S361-phase-e1-vn-tokenization.md
        § DD-1 (Protocol vs ABC — Protocol chosen per LlmExtractorPort precedent
        at packages/application/news/ports/llm_extractor_port.py:28).
"""

from __future__ import annotations

from typing import Protocol

__all__ = ["TextTokenizerPort"]


class TextTokenizerPort(Protocol):
    """Tokenize VN text into syntactic word units.

    Implementations MUST:
    - Be deterministic — same input string => same output token list (D-059 R2
      compliance; verifier grep-asserts determinism smoke at S363).
    - Return [] for empty / whitespace-only input (NOT raise).
    - Preserve multi-syllable VN words as single tokens where the underlying
      library supports it (e.g. "co_phieu" as ONE element; specific separator
      chosen by adapter at IMPL time).

    Implementations MAY:
    - Strip punctuation / normalize whitespace at their discretion.
    - Cap input text length at a sensible upper bound (e.g. 100K chars) and
      return [] for over-long inputs (callers shall check token list length).

    I-S1 compliance: tokenizer path is LLM-free by construction — no LLM SDK
    imported, no anthropic/openai call in any implementation of this port.

    D-059 compliance (ALL implementations):
    - R1 (datetime-no-tz): N/A tokenizer is pure text transform; no datetime.
    - R2 (unseeded RNG): tokenizer MUST be deterministic; no random state.
    - R4 (time.time-in-domain): N/A infrastructure adapter, not domain.
    """

    def tokenize(self, text: str) -> list[str]:
        """Return ordered list of token strings for ``text``."""
        ...
