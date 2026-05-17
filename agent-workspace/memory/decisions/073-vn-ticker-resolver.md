---
id: D-073
title: VN Ticker Resolver v0 — Alias Table + difflib Fuzzy Match
status: ACCEPTED
severity: IMPL
proposed_at: 2026-05-17
proposed_by: sandwich-dev S371 (IMPL session; plan-032-S370-phase-e4-vn-ticker-resolver.md)
ratified_by: (pending S372 sandwich-verifier AP-1 VERIFY session)
supersedes: null
superseded_by: null
adr_slot: D-073 (follows D-072 VN claim extraction wrapper AUGMENT; sub-plan 031)
phase: Phase E.4 (FOURTH + FINAL sub-plan of Phase E — Vietnamese NLP entry)
parent_plan: agent-workspace/session-plans/pending/032-S370-phase-e4-vn-ticker-resolver.md
---

# D-073: VN Ticker Resolver v0 — Alias Table + difflib Fuzzy Match

## Context

Phase E.4 delivers the Vietnamese ticker-entity resolver layer for StockForge.
Before this ADR, the only ticker resolution in the codebase was a 2-4 char
uppercase filter at `packages/infrastructure/news/claude_llm_extractor.py:238-241`
which would miss common Vietnamese company-name variants ("vinhomes" lowercase,
"Vinhomes" full name, "Công ty Cổ phần Vinhomes" formal name) entirely.

Per parent plan-028 DD-6 (FRESH-MODULE + ALIAS-TABLE strategy) + supplement
§ I.4 + A-14 § 7.7 anti-pattern veto: centralizing VN ticker resolution from
day 1 is cleaner than retro-fixing 6 scattered ad-hoc lookups later.

## Decision

### DD-1: FRESH MODULE + ALIAS TABLE

New module: `apps/_shared/entities/vn_ticker_resolver.py`
New alias table: `agent-workspace/ubiquitous-language/vn_ticker_aliases.md`
New CLI: `apps/cli/resolve_vn_tickers.py`

Ticker value object (`packages/contracts/types/ticker.py`) is UNCHANGED.
Resolver is application-tier capability (variant text → canonical Ticker);
separation-of-concerns per DDD tactical patterns.

### DD-2: CONCRETE CLASS NOT PROTOCOL

Single concrete class `VnTickerResolver` with `resolve(mention: str) -> ResolutionResult`.
No Protocol port for v0 — Karpathy P2 simplicity. No swap requirement until
n>200 tickers OR spaCy NER / transformer backend surfaces (per AQ-9 trigger).
Protocol-ification = AP-23 first-instance HOLD.

### DD-3: MARKDOWN ALIAS TABLE (NOT Python dict literal)

Alias table lives at `agent-workspace/ubiquitous-language/vn_ticker_aliases.md`
as hand-curated markdown (UL artifact). Project-owner curatable without Python
knowledge. Git-diff-friendly. Parser: stdlib `re` regex.

Divergence from sub-plan 030 DD-5 (Python dict literal): lexicon is keyword-WEIGHT
scoring data (close to algorithm); alias-table is entity-mapping reference data
(curated by domain experts). Markdown is the correct tier for UL artifacts.

### DD-4: RULE 16 MODE 2 SATISFACTION

`resolution_confidence: float` in [0.0, 1.0] = `difflib.SequenceMatcher.ratio()`.
Pure-function; deterministic across Python releases per stdlib stability guarantee.
LLM is NEVER invoked in the resolution path. Satisfies I-S1 (NO LLM math) and
Rule 16 mode 2 (deterministic-pipeline echo) by construction.

### DD-5: _build_claim INTEGRATION — SURGICAL EDIT WITH DI GRACEFUL DEGRADATION

`ClaudeLlmExtractor` dataclass gets new field:
```python
ticker_resolver: VnTickerResolver | None = None
```

When `None` (default): backward-compat 2-4 char uppercase filter preserved.
When injected: resolver path per plan-032 DD-5.
Production wiring (`ClaudeLlmExtractor(ticker_resolver=VnTickerResolver())`) is
a separate per-AQ-8 decision; CLI default remains no-arg for v0.

### DD-6: AMBIGUITY POLICY — EXPLICIT AMBIGUOUS, NO SILENT PICK

When `difflib.get_close_matches` returns >=2 candidates within cutoff window
AND no exact/case-insensitive/diacritics-stripped match wins, resolver returns:
```python
ResolutionResult(
    resolution_method=ResolutionMethod.AMBIGUOUS,
    candidates=tuple[Ticker, ...],  # ALL candidates populated
    resolution_confidence=0.0,
    canonical_ticker=None,
)
```

`_build_claim` treats AMBIGUOUS as skip (matches current 2-4 char filter behavior
for unresolved entries). NO silent-pick on ambiguity per I-S22 data lineage.

This design pre-empts Rule 17 charter-tier escalation: AMBIGUOUS-explicit-surface
preserves audit trail + lets future calibration cycle decide skip-vs-emit policy.
STEP 0.3 Rule 17 gate did NOT fire (LIKELY-VERY-LOW as projected per plan-032 § M).

### DD-7: VN30 UNIVERSE SEED ONLY

Alias table seeds ~30 VN30 tickers × ~6 aliases each = ~180 alias entries v0.
Hand-curatable in ~2 hours by project owner. HNX-30 + UPCoM expansion = E.4-V2.

### DD-8: DIFFLIB CUTOFF = 0.85 ARCHITECT DEFAULT

`difflib.get_close_matches(cutoff=0.85, n=3)`.
Catches "vinhomes" → VHM at ratio ~0.86; rejects "vincomeBank" → VCB at ~0.6.
Validated by test fixtures TC6-TC17 in `test_vn_ticker_resolver.py`.

## Resolution Method Taxonomy (I-S22 data lineage)

| Method | Confidence | When |
|---|---|---|
| EXACT | 1.0 | Canonical 3-char symbol matched case-sensitively |
| CASE_INSENSITIVE | 1.0 | Alias matched ignoring case |
| DIACRITICS_STRIPPED | 0.95 | Alias matched after stripping Vietnamese diacritics |
| FUZZY | 0.85-0.99 | difflib.get_close_matches single candidate |
| AMBIGUOUS | 0.0 | Multiple distinct tickers within cutoff window |
| UNKNOWN | 0.0 | No alias match found |

## Consequences

**Positive**:
- Centralizes VN ticker resolution (no more ad-hoc 2-4 char filters)
- Catches "vinhomes" lowercase that old filter missed entirely
- Full audit trail via ResolutionResult.resolution_method + confidence + matched_alias
- No new external dependency (stdlib difflib only)
- Zero ExtractedClaim schema change (mentioned_tickers tuple[Ticker, ...] preserved)
- 1086/1086 test baseline preserved (backward-compat DI default=None)

**Negative / Risks**:
- VN30 coverage only v0; production miss rate unknown until corpus measurement
- difflib cutoff 0.85 is architect default; may need empirical tuning
- Alias table is hand-curated; maintenance burden grows with VN universe expansion

## Revisit Triggers

1. **E.4-V2 expansion**: alias-table grows to n>100 tickers OR >=3 unresolved
   production mentions surface in extractor logs
2. **Cutoff tuning**: D5 CLI smoke shows <70% recall OR >5% false-positive rate
   on real VN news corpus
3. **Protocol-ification**: second resolver backend (spaCy NER / transformer)
   surfaces empirically when VN universe grows to n>200 tickers
4. **Production wiring**: ClaudeLlmExtractor(ticker_resolver=VnTickerResolver())
   at ingest_news_*.py CLI — separate ADR-tracked decision per AQ-8
5. **Persistence**: production audit query surfaces need for resolution-method
   trail on persisted ExtractedClaim — revisit E.4-V2

## Operational Notes

- Alias table location: `agent-workspace/ubiquitous-language/vn_ticker_aliases.md`
- Version bump discipline: every alias table edit bumps `version:` in frontmatter
- Resolution audit preserved via ResolutionResult fields (I-S22 lineage)
- D-059 compliance: resolver is pure-function; no datetime.now() / RNG / time.time()

## Phase E DONE Attestation (per plan-032 § N)

With S371 IMPL complete + S372 verifier PASS:
- E.1 Tokenization (D-070): SHIPPED S362, VERIFIED S363
- E.2 Sentiment Lexicon (D-071): SHIPPED S365, VERIFIED S366
- E.3 Claim Extraction Wrapper (D-072): SHIPPED S368, VERIFIED S369
- E.4 VN Ticker Resolver (D-073): SHIPPED S371, VERIFIED S372 (pending)

Phase E DONE → Phase F-prime master-plan dispatch unblocked per plan-028 § M.1.
