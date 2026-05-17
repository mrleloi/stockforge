"""VnTokenizer — concrete TextTokenizerPort adapter using pyvi.

pyvi selected via STEP 0.3-0.5 empirical evaluation on 36-article VN
financial-news corpus (NDH/Vietstock/VietnamBiz):

  Candidate     Quality   Perf (ms/1000tok)  Install MB  License
  underthesea   81.8%     27.2               ~29 MB      Apache-2.0
  pyvi          75.7%     7.5                ~29 MB      MIT
  whitespace     0.0%      0.2                0 MB       own

Selection rationale (per plan-029 § C STEP 0.5 architect recommendation):
  Quality gap = 81.8 - 75.7 = 6.1% < 10% threshold.
  "IF pyvi quality within 10% of underthesea: pick (c) — simplicity +
   license safety wins over marginal quality gap."
  pyvi MIT is simpler license footprint; 3.6x faster perf; within quality
  threshold. CHARTER-TIER GATE did NOT fire (underthesea = Apache-2.0,
  NOT GPL-3.0; historical docs were stale).

D-059 compliance:
- R1 (datetime-no-tz): N/A — tokenizer is pure text transform; no datetime.
- R2 (unseeded RNG): N/A — tokenizer is deterministic per Protocol contract;
  verifier smoke at S363 confirms.
- R4 (time.time-in-domain): N/A — infrastructure adapter, not domain.

I-S34 HARD REJECT compliance: STEP 0.6 verified pyvi has ZERO transitive
deps in [patchright, playwright_stealth, fake-useragent, UndetectedAdapter,
StealthyFetcher, cloudflare-solver]; verifier re-grep at S363.

I-S1 compliance: tokenizer is LLM-free by construction — no LLM SDK
imported or invoked in this module.

Source: agent-workspace/session-plans/pending/029-S361-phase-e1-vn-tokenization.md
        § D2 + DD-2 (SELECTED library = pyvi per STEP 0.5);
        agent-workspace/memory/decisions/070-vn-tokenizer-library.md
        (ADR records selection rationale + revisit triggers).
"""

from __future__ import annotations

import logging
import re
from collections.abc import Callable
from dataclasses import dataclass, field
from typing import cast

__all__ = ["VnTokenizer", "WhitespaceTokenizer"]

_log = logging.getLogger(__name__)

# Vietnamese diacritic character class for whitespace tokenizer
_VN_DIACRITIC_CHARS = (
    "àáảãạâầấẩẫậăằắẳẵặ"
    "èéẻẽẹêềếểễệ"
    "ìíỉĩị"
    "òóỏõọôồốổỗộơờớởỡợ"
    "ùúủũụưừứửữự"
    "ỳýỷỹỵđ"
    "ÀÁẢÃẠÂẦẤẨẪẬĂẰẮẲẴẶ"
    "ÈÉẺẼẸÊỀẾỂỄỆ"
    "ÌÍỈĨỊ"
    "ÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢ"
    "ÙÚỦŨỤƯỪỨỬỮỰ"
    "ỲÝỶỸỴĐ"
)

_WHITESPACE_TOKEN_RE = re.compile(
    rf"[^\w{re.escape(_VN_DIACRITIC_CHARS)}]+"
)


@dataclass(frozen=True, slots=True)
class WhitespaceTokenizer:
    """Naive whitespace+punctuation tokenizer. Zero-dependency baseline.

    DEFAULT-LOW-QUALITY: does NOT preserve multi-syllable VN words (e.g.
    'co phieu' -> ['co', 'phieu'] = 2 tokens instead of ['co_phieu'] = 1).
    Use only as fallback per AQ-7 if SELECTED library install fails OR all
    3 candidates score <30% quality threshold per STEP 0.3.

    Quality on 36-article VN financial-news corpus STEP 0 eval: 0.0%
    (all multi-syllable terms split; no compound-word awareness).

    Source: agent-workspace/session-plans/pending/029-S361-phase-e1-vn-tokenization.md
            § D2 DD-2 AQ-7 (default fallback design).
    """

    selected_library: str = "whitespace-baseline-v0"

    def tokenize(self, text: str) -> list[str]:
        """Return tokens split on whitespace + punctuation; preserve diacritics."""
        if not text or not text.strip():
            return []
        return [t for t in _WHITESPACE_TOKEN_RE.split(text) if t]


@dataclass
class VnTokenizer:
    """VN tokenizer wrapping pyvi behind TextTokenizerPort.

    pyvi is loaded lazily on first tokenize() call so that the adapter
    module can be imported in environments where pyvi is not installed
    (e.g. test environments using WhitespaceTokenizer only).

    Quality on 36-article VN financial-news corpus STEP 0 eval: 75.7%
    (multi-syllable VN financial terms preserved as single underscore-joined
    tokens, e.g. 'co_phieu', 'thi_truong').

    Library version: pyvi==0.1.1 (MIT license; pinned in pyproject.toml).
    """

    selected_library: str = "pyvi==0.1.1"
    # _tokenize_fn is a Callable loaded lazily; typed as object to avoid
    # disallow_any_explicit=true constraint (pyvi lacks type stubs; per
    # plan-029 DD-6: use object field + cast at call site instead of Any).
    _tokenize_fn: object = field(default=None, init=False, repr=False)

    def tokenize(self, text: str) -> list[str]:
        """Return ordered list of token strings for ``text``.

        pyvi.ViTokenizer.tokenize returns a single space-separated string
        with multi-syllable VN words joined by underscores (e.g. 'co_phieu
        thi_truong'). We split on whitespace to produce a list[str].
        """
        if not text or not text.strip():
            return []
        if self._tokenize_fn is None:
            self._load_lib()
        # pyvi lacks type stubs; cast to Callable via intermediate object
        # (plan-029 DD-6: object field + cast at call site; n=2 type:ignore
        # comment is within DD-6 n<3 threshold before stub-vendoring)
        fn = cast(Callable[[str], str], self._tokenize_fn)
        raw = fn(text)
        # pyvi returns str "cổ_phiếu thị_trường"; split to list[str]
        return raw.split()

    def _load_lib(self) -> None:
        """Lazy import of pyvi.ViTokenizer. Caches function reference for reuse."""
        try:
            from pyvi import ViTokenizer  # type: ignore[import-not-found]  # pyvi has no stubs

            self._tokenize_fn = ViTokenizer.tokenize
            _log.debug("VnTokenizer: pyvi loaded successfully")
        except ImportError as exc:
            raise RuntimeError(
                f"VnTokenizer requires pyvi; install via "
                f"`pip install {self.selected_library}`. Underlying: {exc}"
            ) from exc
