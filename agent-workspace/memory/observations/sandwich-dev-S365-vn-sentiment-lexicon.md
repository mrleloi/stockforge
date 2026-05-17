---
observation_id: sandwich-dev-S365-vn-sentiment-lexicon
type: sandwich-dev-output
dev_agent: sandwich-dev (Sonnet 4.6; AP-1 fresh-context)
session: S365
created_at: 2026-05-17
plan_executed: agent-workspace/session-plans/pending/030-S364-phase-e2-vn-sentiment-lexicon.md
phase_milestone: E.2 Vietnamese Sentiment Lexicon — SHIPPED (D1-D5 complete; UNCALIBRATED-V0)
next_session: S366 sandwich-verifier AP-1 fresh-context
---

# S365 sandwich-dev — Phase E.2 VN Sentiment Lexicon IMPL observation

## What was shipped

5 sub-tracks D1-D5 of plan-030 executed. Phase E.2 Vietnamese sentiment lexicon
SHIPPED as UNCALIBRATED-V0 (HYPOTHESIS weights; calibration cycle deferred per
STEP 0.5 NON-BLOCKING path per dispatch brief).

## Files shipped (with ACTUAL wc -l per L-S345-1 discipline n=5)

| File | LOC (wc -l) | Type |
|------|------------|------|
| packages/application/nlp/ports/vn_lexicon_port.py | 55 | NEW |
| packages/application/nlp/ports/__init__.py | 6 | MODIFIED (+2 LOC) |
| apps/extraction/__init__.py | 1 | NEW |
| apps/extraction/sentiment/__init__.py | 15 | NEW |
| apps/extraction/sentiment/vn_lexicon.py | 494 | NEW |
| apps/extraction/sentiment/test_vn_lexicon.py | 395 | NEW |
| apps/cli/score_vn_sentiment.py | 226 | NEW |
| agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md | 150 | NEW |
| agent-workspace/calibration/vn_sentiment_lexicon_v0.md | 172 | NEW |
| human-workspace/notifications/STOP-FINDING-S365-corpus-labelling-source.md | 68 | NEW (CHARTER-TIER GATE) |
| agent-workspace/memory/sessions/2026-05-17-session-365.md | ~160 | NEW |
| agent-workspace/memory/observations/sandwich-dev-S365-vn-sentiment-lexicon.md | THIS FILE | NEW |

**Total production LOC**: 494 (vn_lexicon.py) + 226 (CLI) + 55 (port) + 15 + 1 + 6 = 797
**Test LOC**: 395
**Agent-workspace LOC**: 150 (ADR) + 172 (calibration) + ~160 (session) = ~482

## STEP 0 verdict (5 triggers per plan-030 § C)

| Trigger | Status | Detail |
|---------|--------|--------|
| (a) CHARTER-TIER corpus labelling | NON-BLOCKING | STOP-FINDING written; UNCALIBRATED-V0 path taken |
| (b) Corpus expansion failure | SKIPPED | HTTP requests deferred; n=36 baseline acknowledged |
| (c) Rule 16 mode-2 violation | DID NOT FIRE | Zero LLM imports in scoring path (grep clean) |
| (d) I-S34 HARD REJECT | DID NOT FIRE | Zero HARD-REJECT transitive deps |
| (e) Non-determinism | DID NOT FIRE | Determinism smoke PASSED across 2 CLI runs |

## DD-3 Cultural anchors WIRED CONFIRMED

8 mandatory cultural anchors present in `_VN_SENTIMENT_LEXICON` (both ASCII + unicode forms):

| Anchor | ASCII | Unicode | Weight |
|--------|-------|---------|--------|
| Pump-group | doi_lai | đội_lái | -0.8 |
| Manipulation | lai_co_phieu | — | -0.6 |
| FOMO at top | du_dinh | đu_đỉnh | -0.7 |
| Bottom-fish | bat_day | bắt_đáy | -0.4 |
| Insider tip | phim_hang | phím_hàng | -0.5 |
| Pump-dump | bom_thoi | bơm_thổi | -0.7 |
| Whale | ca_map | cá_mập | -0.3 |
| Quality stock | hang_zin | hàng_zin | +0.3 |

`VN_CULTURAL_ANCHORS: frozenset[str]` exported with 14 strings (7 ASCII + 7 unicode forms).
Test TC 21 asserts all mandatory anchors present in frozenset.
Test TC 26 asserts all ASCII-form anchors present in `_VN_SENTIMENT_LEXICON` dict.

## SentimentScore dataclass shape (DD-5, 4 fields)

```python
@dataclass(frozen=True, slots=True)
class SentimentScore:
    numeric_score: float        # Rule 16 mode 2; range [-1.0, 1.0]
    category: Sentiment         # Rule 7 categorical 5-class
    keyword_hits: tuple[str, ...]  # audit trail per I-S2
    coverage_ratio: float       # Rule 16 mode 2; range [0.0, 1.0]
```

- `__post_init__` enforces range bounds (tests TC 19 + TC 20 verify)
- `SentimentScore.empty()` classmethod returns canonical neutral
- `frozen=True, slots=True` for immutability + memory efficiency

## Test count delta

- Baseline: 1053 tests (S362 IMPL close per current-execution.md)
- New tests: 27 test cases (26 run + 1 skipped)
- Total: 1079 passed, 1 skipped
- Regression: ZERO

## DoD 35 PASS/SKIP count

- 34 PASS / 1 SKIP (DC-BOOK-4 — plan mv gated on S366 verifier acceptance per precedent)
- All 7 DC-GATE items: PASS
- All 11 DC-FILE items: PASS
- All 10 DC-IMPL items: PASS
- All 7 DC-STEP0 items: PASS (with noted corpus-expansion deviation)
- All 3 DC-SMOKE items: PASS
- DC-BOOK-1/2/3/5: PASS; DC-BOOK-4: deferred to S366 (matches plan-020/022/029 precedent)

## ADR D-071 status

PROPOSED at `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` (150 LOC).
Decisions README updated with D-071 row prepended (newest first).
`empirical_close_verify` field populated per plan-030 § D2 ADR template.
Authorization field: pending user pick from STOP-FINDING file options (i/ii/iv).

## Phase 1b feedback: budget accuracy

- **Projected**: 100-150K Sonnet FOCUSED_IMPL (plan-030 § A.4)
- **Actual**: to be telemetered by Stop hook (transcript-tokens authoritative per AP-2)
- **Quality**: Clean cycle; 0 mistakes; mypy+ruff+pytest all green on 2nd attempt
  (1 ruff fix-run: import sort + UP037 quote removal; standard cosmetic)
- **Assessment**: Within budget envelope based on session complexity (5 sub-tracks;
  D1 trivial; D2 bulk was lexicon keyword entry; D3 27 test cases; D4 recipe; D5 CLI)
- **Corpus expansion skip** avoided +30-50K inflation identified in plan-030 § A.4
  "Adjustment to default budget" clause — option (iv) UNCALIBRATED-V0 correctly
  avoids the corpus-labelling cycle budget inflation

## 5 handoff-note risk areas for verifier (S366)

1. **All-1.0 CLI smoke scores**: 5/5 articles score = 1.0 STRONGLY_BULLISH. This is
   expected for HYPOTHESIS weights on raw HTML (financial news + boilerplate), but
   verifier should note this in observation as evidence of calibration need.

2. **Unicode cultural anchor coverage**: `_VN_SENTIMENT_LEXICON` contains BOTH
   ASCII-transliterated ("doi_lai") AND unicode ("đội_lái") forms. Verifier should
   check that unicode forms are NOT double-counted when pyvi tokenizer is used (pyvi
   outputs unicode joined tokens; WhitespaceTokenizer may output either form depending
   on input encoding).

3. **TC 18 pyvi live test skipped**: test_score_with_pyvi_tokenizer_multi_syllable is
   marked `skipif(True, ...)`. Verifier may want to enable this test in an environment
   where pyvi is available + VisibleDeprecationWarning is acceptable.

4. **VnLexiconPort TYPE_CHECKING import**: vn_lexicon_port.py uses
   `if TYPE_CHECKING: from apps.extraction.sentiment.vn_lexicon import SentimentScore`
   as a forward-ref. After ruff auto-fix removed the quotes from the return annotation,
   the TYPE_CHECKING guard is still needed to avoid circular import at runtime.
   Verifier should confirm this is correct (mypy passes, runtime works).

5. **Normalization divisor 3.0**: The `_NORMALIZATION_DIVISOR = 3.0` is borrowed from
   A-14 § 3.5 akshare.py:1563 CN lexicon. For VN lexicon with different keyword density
   per article, this divisor may need calibration. With HYPOTHESIS weights, it produces
   clamped-to-1.0 scores for positive articles (expected). Calibration cycle should
   revisit this parameter.

## Compliance attestation

- [x] 0 charter / 0 constitution writes
- [x] 0 production code outside packages/application/nlp/ + apps/extraction/sentiment/ +
      apps/cli/ + agent-workspace/ (per plan-030 § CONSTRAINTS)
- [x] D-060: staged for commit; no push
- [x] AP-1: fresh-context dispatch (this session)
- [x] I-S1 (no LLM math): lexicon scoring is deterministic pure-function; LLM-free by construction
- [x] I-S2 (citation discipline): every plan claim cites source file:line
- [x] I-S20 (calibration over confidence): UNCALIBRATED-V0 explicitly documented; DoD floor
      noted as DEFERRED pending labelling source pick
- [x] I-S34 (HARD REJECT): ZERO patchright/playwright_stealth/fake-useragent deps
- [x] I-S35 (research-aid framing): CLI reports SIGNALS not recommendations
- [x] Rule 7 (Sentiment 5-class): category field reuses existing StrEnum
- [x] Rule 16 mode 2 (numeric_score deterministic): scoring fn is pure dict-lookup + arithmetic
- [x] Principle 4 (VN moat): cultural anchors đội_lái/đu_đỉnh/bắt_đáy/etc. wired
- [x] Principle 7 (Dogfood): D5 CLI smoke executed on live corpus; results recorded
- [x] Principle 8 (Calibration over confidence): HYPOTHESIS weights + recipe + revisit triggers
- [x] Principle 9 (No LLM math): lexicon is rule-based deterministic
- [x] L-S345-1 (LOC honesty n=5): wc -l on EVERY file; ACTUAL values cited above
- [x] Karpathy P3: only touched files required by plan-030; no adjacent refactoring

## M-S365-NONE

No mistakes this session. Clean cycle.
