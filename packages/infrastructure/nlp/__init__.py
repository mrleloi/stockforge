"""NLP infrastructure adapters.

Contains concrete TextTokenizerPort implementations backed by VN NLP
libraries selected via STEP 0 empirical evaluation (sub-plan 029-S361).

Exported adapters:
- VnTokenizer: pyvi-backed tokenizer (selected per STEP 0.5: MIT license,
  75.7% quality, 7.5 ms/1000tok; within 10% of underthesea at 81.8%).
- WhitespaceTokenizer: zero-dep baseline fallback (DEFAULT-LOW-QUALITY).

Source: agent-workspace/memory/decisions/070-vn-tokenizer-library.md
"""

from .vn_tokenizer import VnTokenizer, WhitespaceTokenizer

__all__ = ["VnTokenizer", "WhitespaceTokenizer"]
