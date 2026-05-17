---
id: 072
title: VN Claim Extraction Wrapper — AUGMENT existing extractor + anthropic→subagent default-flip + 2 new ExtractedClaim fields
status: PROPOSED
date: 2026-05-17
authors: sandwich-dev S368
level: IMPL
supersedes: []
superseded_by: []
related:
  - "D-050 ACCEPTED 2026-05-09 anthropic→subagent SYSTEMIC"
  - "D-051 ACCEPTED 2026-05-09 news-extractor refactor (transport flip + cli transport authored)"
  - "D-052 ACCEPTED 2026-05-09 SDK dep removal (anthropic dep from pyproject.toml; still deferred per § A.3)"
  - "D-070 PROPOSED pyvi tokenizer"
  - "D-071 PROPOSED VN sentiment lexicon UNCALIBRATED-V0"

empirical_close_verify: |
  - ClaudeLlmExtractor instantiable with new DI signature + extract() returns ExtractedClaim with new fields
  - mypy --strict + ruff + pytest on packages/infrastructure/news/ + packages/domain/news/ exit 0
  - test_adapters.py 27 existing tests PASS unchanged + 6 new tests PASS (33 total in test_adapters.py)
  - ZERO `import anthropic` / `from anthropic` in packages/infrastructure/news/claude_llm_extractor.py (grep-asserted by TC D3-5)
  - `_default_transport` symbol REMOVED from claude_llm_extractor.py (grep-asserted by TC D3-4)
  - Drop-in transport make_claude_cli_news_transport() factory consumed verbatim from claude_cli_news_transport.py (UNCHANGED per DD-7)
  - STEP 0 dogfood smoke records determinism PASS + articles processed via D5 CLI with stub-transport
  - DC-FILE-1 through DC-FILE-7 all pass per plan-031 § F
---

## Decision

ClaudeLlmExtractor AUGMENTED in-place per parent plan-028 DD-5 EXISTING-EXTRACTOR-AUGMENT
strategy:

(a) 2 NEW DI fields:
    - `tokenizer: TextTokenizerPort = field(default_factory=WhitespaceTokenizer)` — VnTokenizer
      injection adds pre-LLM hint line to system prompt for multi-syllable VN term awareness
      (DD-5); default WhitespaceTokenizer = no hint = backward-compat
    - `lexicon: VnLexiconPort | None = None` — VnSentimentLexicon injection scores article
      body post-LLM for deterministic lexicon_score + mentioned_pump_anchors (DD-4); default
      None = skip scoring = backward-compat

(b) DEFAULT TRANSPORT FLIPPED to `make_claude_cli_news_transport()` factory per D-050 SYSTEMIC
    + user memory rule `anthropic_api_to_subagent` (verbatim 2026-05-09). `_default_transport`
    function REMOVED. `import anthropic` line REMOVED. Tests inject stub via constructor kwarg
    (existing pattern at test_adapters.py; unchanged).

(c) 2 NEW ExtractedClaim fields (packages/domain/news/models/extracted_claim.py):
    - `lexicon_score: float = 0.0` — deterministic-pipeline echo per Rule 16 mode 2
    - `mentioned_pump_anchors: tuple[str, ...] = field(default_factory=tuple)` — deterministic
      frozenset intersection of VN_CULTURAL_ANCHORS with keyword_hits

Both new fields are computed POST-LLM by _compute_lexicon_artifacts(); LLM never emits them.
System prompt updated to explicitly instruct LLM NOT to emit these fields.

## Pattern source

Sub-plan 029 (D-070 pyvi VnTokenizer) + sub-plan 030 (D-071 VN sentiment lexicon
UNCALIBRATED-V0) — DI substrate consumed verbatim. THIS sub-plan integrates both into existing
claim extraction surface.

D-050 SYSTEMIC mandate + user memory rule (verbatim 2026-05-09) — news-extractor refactor was
deferred to D-051 per D-050 § Deferred. D-051 shipped the transport module (claude_cli_news_transport.py)
but left _default_transport as NotImplementedError stub (per D-051 empirical_close_verify text).
D-052 shipped the stub removal decision but the code change was NOT applied at time of writing
(D-052 ADR ACCEPTED but code unchanged at S367 architect VBW read — plan-031 carries the actual
implementation). THIS sub-plan (plan-031) executes the final removal in code:
- REMOVES `_default_transport` function (lines 80-99 in pre-S368 version)
- REMOVES `import anthropic` lazy-import at pre-S368 L84
- FLIPS transport field default_factory to make_claude_cli_news_transport

D-052 (anthropic dep removal from pyproject.toml) explicitly NOT in scope — separate cleanup
ADR per D-050 § Deferred. anthropic remains in pyproject.toml until D-052 is executed.

## DI graceful-degradation

| Construction | tokenizer | lexicon | lexicon_score | mentioned_pump_anchors | transport |
|---|---|---|---|---|---|
| `ClaudeLlmExtractor()` (no-arg) | WhitespaceTokenizer | None | 0.0 | () | claude CLI factory |
| Production wire-up | VnTokenizer() | VnSentimentLexicon(VnTokenizer()) | computed | computed | claude CLI factory |
| Tests | WhitespaceTokenizer | None | 0.0 | () | stub lambda |

## Rule 16 mode 2 satisfaction (by construction)

- `lexicon_score: float` is `lexicon.score(article.body_excerpt).numeric_score` (deterministic
  dict-lookup + float arithmetic; NO LLM; per _compute_lexicon_artifacts() in extractor)
- `mentioned_pump_anchors: tuple[str, ...]` is
  `tuple(sorted(VN_CULTURAL_ANCHORS & set(lexicon.score(body).keyword_hits)))` (deterministic
  frozenset intersection over sorted-tuple result; NO LLM; per _compute_lexicon_artifacts())
- LLM still emits sentiment (5-class categorical per Rule 7 UNCHANGED); LLM does NOT emit
  lexicon_score or mentioned_pump_anchors per system-prompt NOTE clause added in D2

## Files modified

- `packages/domain/news/models/extracted_claim.py` — D1: 2 new fields + __post_init__ bounds check
- `packages/infrastructure/news/claude_llm_extractor.py` — D2: transport flip + DI fields + augment
  + import removals + system-prompt update + _build_effective_system_prompt + _compute_lexicon_artifacts
- `packages/infrastructure/news/test_adapters.py` — D3: 6 new test cases
- `apps/cli/extract_vn_claims.py` — D5: NEW integration smoke CLI
- `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` — THIS file (D4)

## Revisit triggers (per AP-7 anti-vacuous-defer)

1. **claude CLI substrate unavailable in production runtime** → revert to stub transport via
   constructor kwarg (D-050 § Edge cases path); CHARTER-TIER consideration if widespread
   deployment without claude CLI available

2. **LLM-output drift surfaces volunteer lexicon_score or mentioned_pump_anchors emission** →
   tighten system prompt (preferred: add stronger RULE clause); defense-in-depth already in place
   (_build_claim ignores these fields from LLM JSON; deterministic override always applies)

3. **Lexicon coverage <50% on production extraction** (lexicon_score = 0.0 for >70% of claims)
   → triggers sub-plan 030-V2 calibration cycle per ADR D-071 revisit trigger 1; adjust
   lexicon weights or expand vocabulary for production VN financial news patterns

## Risks

- RM1: claude CLI subprocess unavailable in test/CI env → mitigated via test stub-transport
  (existing pattern at test_adapters.py; D3 tests use lambda stub)
- RM2: lexicon coverage on real corpus unknown until calibration cycle ships → ADR D-071
  revisit trigger 1 monitors; D5 CLI smoke records distribution
- RM3: System prompt NOTE clause adds ~10 tokens to every call → minor cost increase (~$0.0001
  per call); negligible at v0 throughput

## Source

- plan-031 (S367 architect) § D DD-1 through DD-7 + § E D1-D5
- agent-workspace/memory/decisions/050-S227-anthropic-to-subagent-systemic.md (D-050 CHARTER)
- agent-workspace/memory/decisions/051-S228-news-extractor-subagent-refactor.md (D-051 transport)
- agent-workspace/memory/decisions/052-S229-anthropic-sdk-codepath-full-removal.md (D-052 removal)
- packages/infrastructure/news/claude_llm_extractor.py (modification target)
- packages/infrastructure/news/claude_cli_news_transport.py (consumed verbatim; DD-7 UNCHANGED)
- packages/domain/news/models/extracted_claim.py (NEW fields)
- agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md (parent plan-028
  DD-5 + AQ-6 + § K.2 anticipated FLAGS)
