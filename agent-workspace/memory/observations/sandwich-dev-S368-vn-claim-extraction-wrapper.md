---
observation_id: sandwich-dev-S368-vn-claim-extraction-wrapper
type: sandwich-dev-output
session: S368
created_at: 2026-05-17
plan_executed: agent-workspace/session-plans/pending/031-S367-phase-e3-claim-extraction-wrapper.md
phase: E.3 VN Claim Extraction Wrapper
status: IMPL-COMPLETE
verifier_session: S369 (AP-1 fresh-context post-S368; sandwich-verifier dispatch)
---

# S368 sandwich-dev — Phase E.3 Claim Extraction Wrapper IMPL observation

## STEP 0 Evaluation Results

### STEP 0.1 — ClaudeLlmExtractor VBW audit (PASS)

File: `packages/infrastructure/news/claude_llm_extractor.py` (pre-S368: 226 LOC)
- `_default_transport` at L80-99 confirmed (function body has `import anthropic` at L84)
- `transport: Callable[[str, str], str] = _default_transport` at L112 confirmed
- `_build_claim` at L159-218 confirmed — modification target for D2

File: `packages/infrastructure/news/claude_cli_news_transport.py` (173 LOC; UNCHANGED per DD-7)
- `make_claude_cli_news_transport()` factory at L158-173 confirmed — returns `Callable[[str, str], str]` matching ClaudeLlmExtractor.transport type
- Already-shipped per D-050 § Deferred D-051

File: `packages/domain/news/models/extracted_claim.py` (pre-S368: 83 LOC)
- ExtractedClaim frozen+slots dataclass + __post_init__ validation chain confirmed
- Modification target for D1 NEW FIELDS

File: `apps/extraction/sentiment/vn_lexicon.py` (494 LOC)
- `VnSentimentLexicon(tokenizer: TextTokenizerPort)` confirmed
- `score(text: str) -> SentimentScore` confirmed
- `VN_CULTURAL_ANCHORS: frozenset[str]` with 15 entries confirmed (8 ASCII + 7 unicode forms)

File: `packages/infrastructure/nlp/vn_tokenizer.py` (148 LOC)
- `VnTokenizer` and `WhitespaceTokenizer` confirmed instantiable

### STEP 0.2 — ExtractedClaim schema audit (PASS)

Pre-S368 ExtractedClaim fields: claim_id, article_id, source_url, source_text_excerpt, claim_text, sentiment, extractor, mentioned_tickers, mentioned_sectors, key_phrases, tone_indicators (all with defaults for latter fields)

New fields per plan-031 DD-3:
- `lexicon_score: float = 0.0` (default 0.0; range [-1.0, 1.0])
- `mentioned_pump_anchors: tuple[str, ...] = field(default_factory=tuple)` (default ())

Backward-compat: confirmed — existing test fixtures construct ExtractedClaim without new fields via extractor (not direct); dataclass field defaults preserve construction validity.

### STEP 0.3 — Claude CLI substrate check (PASS — trigger (a) DID NOT FIRE)

`where claude` → `C:\Users\PC\.local\bin\claude.exe` — claude CLI PRESENT on PATH.
CHARTER-TIER GATE trigger (a) DID NOT FIRE. Transport flip proceeds.

Transport-flip code-change plan confirmed per plan-031 DD-2:
- REMOVE `_default_transport` function (L80-99)
- REMOVE `import anthropic` line (L84, inside removed function)
- CHANGE `transport` field default to `field(default_factory=make_claude_cli_news_transport)`
- ADD `from packages.infrastructure.news.claude_cli_news_transport import make_claude_cli_news_transport`

### STEP 0.4 — Rule 16 mode-2 by-construction audit (PASS — trigger (b) DID NOT FIRE)

Post-D2 claude_llm_extractor.py: grep `import anthropic|from anthropic` → ZERO matches.
Confirmed via TC D3-5 test (asserts zero anthropic import lines in source file).

lexicon_score path: `_compute_lexicon_artifacts()` → `self.lexicon.score(body).numeric_score` — NO LLM.
mentioned_pump_anchors path: `tuple(sorted(VN_CULTURAL_ANCHORS & set(score.keyword_hits)))` — NO LLM.

System prompt updated with NOTE clause: "The fields `lexicon_score` and `mentioned_pump_anchors` are computed POST-LLM by deterministic code (NOT by you). DO NOT include these in your JSON output."

CHARTER-TIER GATE trigger (b) DID NOT FIRE (LLM output drift not detected; deterministic construction prevents it by design).

### STEP 0.5 — Dogfood + determinism smoke (PASS — triggers (c) and (d) DID NOT FIRE)

**I-S34 HARD REJECT**: `pip list | grep -iE "patchright|playwright.stealth|fake.useragent|UndetectedAdapter|StealthyFetcher|cloudflare"` → ZERO matches.

**D-059 determinism smoke**: Plan STEP 0.5 script executed — `c1 == c2` assertion PASSED.
Output: `claim='VHM tang tran', lexicon_score=0.0667, anchors=('doi_lai',)`
"doi_lai" (ASCII form of "đội_lái" pump-group) correctly extracted from body "doi_lai day gia len dinh".

**D5 CLI dogfood**: 3 Vietstock 2026-05-16 HTML articles processed with stub-transport:
- Articles processed: 3
- Claims extracted: 3 (1 per article)
- lexicon_score: min=0.0000, max=0.1667, mean=0.0556 (1/3 non-zero = 33.3%)
- mentioned_pump_anchors: none detected (stub body lacks pump anchors)
- Sentiment distribution: {'neutral': 3} (stub response is hardcoded neutral)
- Determinism: `diff /tmp/extract-smoke-1.json /tmp/extract-smoke-2.json` → empty (PASS)

Note: lexicon_score coverage is low in this smoke because stub body text doesn't contain VN financial keywords. Real corpus dogfood requires live claude CLI; stub-transport smoke validates pipeline shape not content.

## D1 — ExtractedClaim NEW FIELDS

File: `packages/domain/news/models/extracted_claim.py` (83 → 106 LOC; +23 LOC)

Changes:
- Added `lexicon_score: float = 0.0` with Rule 16 mode 2 docstring
- Added `mentioned_pump_anchors: tuple[str, ...] = field(default_factory=tuple)` with docstring
- Added `__post_init__` bounds check for `lexicon_score in [-1.0, 1.0]` — raises ExtractedClaimInvariantError
- Module docstring updated to reference plan-031 additions

## D2 — ClaudeLlmExtractor AUGMENT

File: `packages/infrastructure/news/claude_llm_extractor.py` (226 → 289 LOC; +63 LOC net)

Changes:
- REMOVED `_default_transport` function (L80-99) — anthropic SDK call gone
- REMOVED `import anthropic` line (was L84, inside removed function)
- CHANGED `transport` field default to `field(default_factory=make_claude_cli_news_transport)`
- ADDED imports: `TextTokenizerPort`, `VnLexiconPort`, `make_claude_cli_news_transport`, `VnTokenizer`, `WhitespaceTokenizer`, `VN_CULTURAL_ANCHORS`
- ADDED `tokenizer: TextTokenizerPort = field(default_factory=WhitespaceTokenizer)` DI field
- ADDED `lexicon: VnLexiconPort | None = None` DI field
- ADDED `_build_effective_system_prompt()` — appends hint ONLY when VnTokenizer injected
- ADDED `_compute_lexicon_artifacts()` — deterministic post-LLM lexicon scoring per Rule 16 mode 2
- MODIFIED `extract()` — uses `_build_effective_system_prompt()` + passes `lexicon_artifacts` to `_build_claim`
- MODIFIED `_build_claim()` — accepts `lexicon_artifacts` param + emits new ExtractedClaim fields
- UPDATED system prompt with NOTE clause about lexicon_score + mentioned_pump_anchors
- UPDATED module docstring to reference ANTHROPIC SDK NO LONGER USED + DI + new fields

## D3 — Unit test extensions

File: `packages/infrastructure/news/test_adapters.py` (399 → 590 LOC; +191 LOC)

6 new test cases (TC D3-1 through D3-6):
1. `test_extractor_emits_lexicon_score_when_lexicon_injected` — PASS
2. `test_extractor_emits_mentioned_pump_anchors_when_anchor_in_body` — PASS
3. `test_extractor_emits_zero_lexicon_score_when_lexicon_none` — PASS
4. `test_extractor_default_transport_is_make_claude_cli_news_transport` — PASS
5. `test_extractor_no_anthropic_import_in_module_source` — PASS
6. `test_extractor_lexicon_score_deterministic_across_runs` — PASS

Total test_adapters: 33 tests (27 existing + 6 new). All PASS.

## D4 — ADR D-072

File: `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` (NEW; 133 LOC)

PROPOSED-AT-IMPL per severity-schema. Records:
- AUGMENT strategy rationale (DD-1 through DD-7)
- D-050/D-051/D-052 chain context (D-052 code changes completed here despite ADR pre-existing)
- DI graceful-degradation table
- Rule 16 mode 2 satisfaction clause
- 3 revisit triggers
- Files modified

## D5 — Integration smoke CLI

File: `apps/cli/extract_vn_claims.py` (NEW; 318 LOC)

Functionality implemented:
- `--input-html-dir` + `--limit` for HTML corpus reading
- `--output` for JSON per-claim output
- `--summary` for stdout statistics
- `--use-lexicon/--no-lexicon` for DI toggle
- `--stub-transport` for CI-friendly smoke (no live claude CLI)

Smoke executed successfully (see STEP 0.5 above).

## Verification Summary

| Check | Result |
|---|---|
| `grep import anthropic packages/infrastructure/news/claude_llm_extractor.py` | ZERO (DC-GATE-7 PASS) |
| `_default_transport` symbol | REMOVED (TC D3-4 asserts) |
| `pytest packages/infrastructure/news/test_adapters.py` | 33/33 PASS |
| `pytest -q` full suite | 1085 pass + 1 skip (baseline was 1080; +6 new D3 tests + -1 pre-existing test that became part of D3-4 coverage) |
| `ruff check` on modified files | 0 errors (after auto-fix of import sort + unused import + f-string) |
| I-S34 HARD REJECT grep | ZERO matches |
| Determinism smoke | PASS (cli diff empty + Python assertion c1==c2) |
| Claude CLI substrate | AVAILABLE (C:\Users\PC\.local\bin\claude.exe) |
| STOP-AND-ASK triggers | ALL 4 triggers (a)/(b)/(c)/(d) DID NOT FIRE |

## LOC Delta Summary (per L-S345-1)

| File | Before | After | Delta |
|---|---|---|---|
| extracted_claim.py | 83 | 106 | +23 |
| claude_llm_extractor.py | 226 | 289 | +63 |
| test_adapters.py | 399 | 590 | +191 |
| extract_vn_claims.py | 0 (NEW) | 318 | +318 |
| 072-vn-claim-extraction-wrapper.md | 0 (NEW) | 133 | +133 |

Total delta: +728 LOC across 5 files. Within plan-031 DD-1 Karpathy P3 surgical envelope.

## Deviations from Plan

1. **Ticker.value → Ticker.symbol**: Plan-031 DD-5 D5 CLI snippet used `t.value` for Ticker serialization. Actual Ticker dataclass has `.symbol` attribute (not `.value`). Fixed inline per Karpathy P3 — VBW read confirmed `Ticker(symbol='VHM')`. Not a plan defect (architect doesn't have Bash to verify; dev STEP 0 catch per VBW Protocol).

2. **D-051/D-052 ADR pre-existence**: plan-031 described these as "deferred" but both D-051 and D-052 ADRs already existed as ACCEPTED at time of S368 dispatch. The actual CODE CHANGES described in D-051/D-052 were NOT applied at the time of those ADR writes (claude_llm_extractor.py still had `_default_transport` + `import anthropic` at S367 architect VBW read). Plan-031 correctly identified the gap; this S368 IMPL executes the actual code changes. No contradiction.

## STOP-AND-ASK Findings

None. All 4 triggers (a)/(b)/(c)/(d) DID NOT FIRE per successful STEP 0 evaluation.

## Mistakes

No mistakes this session. (M-S368-NONE)
