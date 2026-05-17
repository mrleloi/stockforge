---
observation_id: sandwich-architect-S370-phase-e4-ticker-plan
type: sandwich-architect-output
architect_agent_id: (this fresh-context dispatch; see dispatch.jsonl for ID)
created_at: 2026-05-17
plan_authored: agent-workspace/session-plans/pending/032-S370-phase-e4-vn-ticker-resolver.md
target_session: S371 (dev FOCUSED_IMPL) + S372 (verifier AP-1)
verifier_session: S372 sandwich-verifier AP-1 (fresh-context post-S371 dev close)
phase_milestone: E.4 VN Ticker Resolver — FOURTH AND FINAL sub-plan of Phase E master plan-028 (per § E sequencing; Phase E DONE at this sub-plan close per § N)
sandwich_architect_has_no_Bash_tool: true (Read/Glob/Grep/Write only per agent template line 5; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
phase_1b_self_calibration: CONSUMED with n=3 vietnamese-nlp-impl precedent from S362 + S365 + S368 (cold-start window NOW CLOSED at task_class level per agent-template L65 threshold)
plan_type: FOCUSED_IMPL sub-plan (5 sub-tracks D1-D5; fourth + final of 4 sub-themes per parent master plan-028 § E decomposition)
parent_plan: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md (PHASE-MASTER-PLAN; sub-plan 032 satisfies its § E.4 contract per DD-6 FRESH-MODULE + ALIAS-TABLE pattern)
predecessor_sub_plans:
  - "029-S361-phase-e1-vn-tokenization (SHIPPED S362 + VERIFIED S363; D-070 PROPOSED; pyvi VnTokenizer)"
  - "030-S364-phase-e2-vn-sentiment-lexicon (SHIPPED S365 + VERIFIED S366 pending non-blocking; D-071 PROPOSED; UNCALIBRATED-V0)"
  - "031-S367-phase-e3-claim-extraction-wrapper (SHIPPED S368 + VERIFIED S369 PASS-WITH-CONCERNS / MERGE-ELIGIBLE: YES; D-072 PROPOSED)"
charter_tier_gate_anticipated: Rule 17 entity-ambiguity-disambiguation (LIKELY-VERY-LOW per § M analysis)
e3_carry_forward: surgical edit at packages/infrastructure/news/claude_llm_extractor.py:238-241 (2-4 char uppercase ticker filter → resolver-backed resolution per parent DD-6 step 4 + S369 verifier risk-area 5 + dispatch brief item 5)
phase_e_done_attestation: § N contract documents Phase E DONE + Phase F-prime entry recommendation
---

# S370 sandwich-architect — Phase E.4 VN Ticker Resolver sub-plan-032 authoring observation

## What was authored

`agent-workspace/session-plans/pending/032-S370-phase-e4-vn-ticker-resolver.md` — FOCUSED_IMPL sub-plan for Phase E sub-theme E.4 VN Ticker Resolver, decomposing into 5 sub-tracks (D1 alias-table markdown + D2 resolver class + D3 unit tests + D4 surgical _build_claim edit + D5 CLI smoke) with FRESH-MODULE + ALIAS-TABLE strategy (per parent plan-028 DD-6) and explicit Rule 17 CHARTER-TIER GATE at STEP 0.3 (LIKELY-VERY-LOW likelihood).

**Plan stats** (architect-internal):
- Total LOC: ~1050 (within recalibrated 150-230K Opus PLAN budget; well-grounded in 30 VBW-read source files)
- 8 DD architecture decisions (DD-1..DD-8) all pre-answered with rationale + adversarial alternates
- 5 sub-tracks D1-D5 in § E with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract
- 33 DC DoD items (≥25 floor satisfied)
- 10 AQ pre-answered (AQ-1..AQ-10)
- 5-source-evidence chain (5 decisions × 5 sources each = 25 citations) in § H
- 10 RM entries (RM1..RM10) with mitigation in § J
- **STEP 0 STOP-AND-ASK trigger inventory** with 2 BLOCKING triggers (alias-table source decision + Rule 17 charter-tier gate)
- **§ M CHARTER-TIER GATE clause** as canonical reference for S371 dev (4 options pre-answered per dispatch brief CRITICAL)
- **§ N Phase E DONE attestation contract** + Phase F-prime entry recommendation per dispatch brief return-summary item 7
- **§ L Conditional next-step** with 4 branches L.1-L.4 covering all post-IMPL paths

## Key architectural decisions (DD-1..DD-8 summary)

| DD | Decision | Pre-decided or CONDITIONAL? |
|---|---|---|
| **DD-1** | **FRESH MODULE + ALIAS TABLE** (NEW apps/_shared/entities/vn_ticker_resolver.py + NEW agent-workspace/ubiquitous-language/vn_ticker_aliases.md) | PRE-DECIDED per parent plan-028 DD-6 + supplement § I.4 + A-14 § 7.7 anti-pattern |
| **DD-2** | **CONCRETE CLASS not Protocol** for VnTickerResolver | PRE-DECIDED per Karpathy P2 simplicity + AP-23 first-instance HOLD (Protocol-ification on second backend) |
| **DD-3** | **MARKDOWN alias table** (NOT Python dict literal) — divergence from sub-plan 030 DD-5 rationale documented | PRE-DECIDED per UL glossary entry pattern + project-owner-curatable-without-Python |
| **DD-4** | **Rule 16 MODE 2 satisfaction** for resolution_confidence via difflib.SequenceMatcher.ratio() | PRE-DECIDED by construction (pure-function determinism) |
| **DD-5** | **Surgical _build_claim edit** with DI graceful degradation (ticker_resolver: VnTickerResolver \| None = None) | PRE-DECIDED per parent DD-6 step 4 + S369 risk-area 5 carry-forward + backward-compat per L-S345-3 precedent |
| **DD-6** | **AMBIGUOUS-explicit-surface** (NOT silent-pick) — preserves I-S22 lineage without Rule 17 charter-tier escalation | PRE-DECIDED per dispatch brief CRITICAL Rule 17 analysis + I-S22 |
| **DD-7** | **VN30 universe seed** (~30 tickers × ~3-5 aliases) | PRE-DECIDED per parent AQ-9 + Charter § First Sub-Scope + glossary § VN30 |
| **DD-8** | **difflib cutoff = 0.85** (architect default; D3 validates; D5 measures) | PRE-DECIDED per empirical balance recall vs precision; ADR D-073 revisit trigger documented |

**Single most important callout**: **DD-6 AMBIGUOUS-explicit-surface** — this is the entire architectural rationale for why Rule 17 charter-tier escalation is LIKELY-VERY-LOW. By making AMBIGUOUS an explicit ResolutionMethod enum member with .candidates: tuple[Ticker, ...] populated, the resolver preserves I-S22 data lineage WITHOUT requiring new charter rule. _build_claim treats AMBIGUOUS as 'skip' which matches the current 2-4 char filter behavior for unresolved entries — zero charter-tier behavioral change vs status quo.

## Phase 1b self-calibration (CONSUMED variant; n=3 vietnamese-nlp-impl precedent — cold-start window CLOSED)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):

30 distinct source files read empirically per § A.4 detailed inventory. Highlights:

1. `agent-workspace/memory/.planner-stats.tsv` — STILL header-only at S370 entry (L-S354-2 + L-S366-4 carry-forward; planner-feedback-loop.sh auto-population gap unchanged after 12+ dogfood cycles)
2. `agent-workspace/memory/current-execution.md` — S362 + S365 + S368 dev RETURN rows confirm n=3 vietnamese-nlp-impl precedent all clean (1053+1079+1085 tests; 0 mistakes each)
3. `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` § E.4 + DD-6 + AQ-9 + § K.2 Rule 17 anticipated FLAG
4. `agent-workspace/session-plans/completed/029-S361 + 030-S364 + 031-S367` — full Phase E precedent chain
5. `agent-workspace/memory/observations/sandwich-verifier-S369-vn-claim-extraction-verify.md` — risk-area 5 carry-forward for E.4 confirmed; sub-plan 031 mv pending → completed AUTHORIZED
6. `packages/contracts/types/ticker.py` — Ticker schema preserved (3-char A-Z/0-9 canonical)
7. `packages/infrastructure/news/claude_llm_extractor.py` — surgical edit site at L238-241 (2-4 char uppercase filter) confirmed via Read
8. `agent-workspace/ubiquitous-language/glossary.md` § Ticker + § VN30 — VN30 thin-slice anchor per Charter § First Sub-Scope
9. Plus 22 more files including ADRs D-070/D-071/D-072 + skill SKILL.md files + pyproject.toml + glob/grep audits

**Calibration parameters extracted**:

- **task_class**: `vietnamese-nlp-impl` (n=3 precedent: S362 + S365 + S368)
- **sample_size**: **3** (cold-start window CLOSED per agent-template L65 threshold)
- **avg_wall_min**: ~39 min (S362 + S365 medium-precision; S368 wall not telemetered)
- **avg tokens_real**: ~155K Sonnet for S362+S365; S368 Opus within recalibrated envelope
- **parallel_hit_rate**: N/A precise (telemetry gap per L-S354-2; declared D3+D4 parallel per § E.D3/D4 disjoint coordination_paths)
- **failure_mode frequency**: 0 mistakes per S362+S365+S368 triple samples
- **Adjustment to default budget**: -10-20K possible swing (fresh module structurally simpler than sub-plan 031 AUGMENT-augment); +5-10K reserve for STOP-AND-ASK conditional
- **Cold-start?**: **NO** for vietnamese-nlp-impl (n=3 threshold met); **NO** for fresh-module shape; **NO** for alias-table shape (markdown variant of sub-plan 030 lexicon-dict-in-python pattern)

**Calibration verdict**: Phase 1b CONSUMED with n=3 vietnamese-nlp-impl precedent NARROW but VALID. Architect honors Karpathy P1 by NOT manufacturing additional precedent; n=3 with 100% clean rate gives directional confidence MEDIUM-HIGH for sub-plan 032 envelope (100-150K Opus FOCUSED_IMPL with -10-20K simpler-shape swing).

## STEP 0 STOP-AND-ASK triggers detail (2 BLOCKING; both pre-answered)

| Trigger | Sub-step | Condition | User decision class | Likelihood |
|---|---|---|---|---|
| **(a) Alias-table source decision** | 0.2 | Project owner unavailable for curation OR demands HSX automation OR rejects markdown source-of-truth | SCOPE-TIER (4 options a/b/c/d enumerated in § STEP 0.2) | LIKELY-LOW (option a default; project-owner-knowledge sufficient) |
| **(b) Rule 17 ambiguity policy** | 0.3 | DD-6 AMBIGUOUS-explicit-surface insufficient AND user requires project-binding policy | CHARTER-TIER (4 options a/b/c/d enumerated in § M) | LIKELY-VERY-LOW (DD-6 already covers known cases per dispatch brief CRITICAL analysis) |

Both triggers have STOP-FINDING file templates ready in § M.2 + § STEP 0.2. Main session dispatches AskUserQuestion gate IF either fires.

## E.3 carry-forward integration point

Per dispatch brief item 5 + S369 verifier risk-area 5 + parent plan-028 § E.4 explicit scope:

**Site**: `packages/infrastructure/news/claude_llm_extractor.py:238-241`

**Current code** (post-S368 commit b6b3877; UNCHANGED at this filter):
```python
tickers = tuple(
    Ticker(str(t)) for t in raw.get("mentioned_tickers", [])
    if isinstance(t, str) and t.isupper() and 2 <= len(t) <= 4
)
```

**E.4 refactor** (D4 surgical edit per DD-5):
- ADD `ticker_resolver: VnTickerResolver | None = None` field to ClaudeLlmExtractor dataclass (mirror existing tokenizer + lexicon DI default pattern at L116-130)
- REPLACE filter to route through resolver when injected:
  - Backward-compat default (ticker_resolver=None): keep current 2-4 char uppercase filter (preserves 1085/1085 post-S368 baseline)
  - Resolver-injected path: for each raw mention, call `self.ticker_resolver.resolve(t)`; emit `result.canonical_ticker` ONLY if (a) resolution_method != UNKNOWN, (b) resolution_method != AMBIGUOUS, (c) resolution_confidence >= 0.85
- Production wiring at apps/cli/ingest_news_*.py = SEPARATE decision (NOT in this sub-plan scope per AQ-8); CLI continues `ClaudeLlmExtractor()` no-arg default

**ZERO ExtractedClaim schema change** — `mentioned_tickers: tuple[Ticker, ...]` preserved per existing model at packages/domain/news/models/extracted_claim.py:58.

## Promotion candidates / discoveries (1st-instance HOLD)

- **L-S370-1 (1st-instance HOLD; AP-23 cluster)**: Sub-plan divergence from precedent-DD without same-shape rationale documentation. Sub-plan 032 DD-3 chose markdown storage (divergence from sub-plan 030 DD-5 Python dict literal); rationale documented explicitly in DD-3 SUB-RATIONALE section. Pattern: when sub-plan DD diverges from precedent-sub-plan DD, explicit SUB-RATIONALE section MUST be in plan output. PROMOTE-on-2nd-instance.
- **L-S370-2 (1st-instance HOLD)**: AMBIGUOUS-explicit-surface as alternative to charter-tier-rule. DD-6 uses explicit enum surface + audit-trail-preservation to avoid Rule 17 charter-tier escalation. Pattern: prefer code-level audit-trail surface over charter-rule mandate when (a) downstream consumer can decide skip-vs-emit policy AND (b) audit log can satisfy verifier sampling. PROMOTE-on-2nd-instance to .claude/skills/ddd-tactical-patterns/.
- **L-S370-3 (1st-instance HOLD; ADR-empirical pattern)**: difflib cutoff = 0.85 architect default WITH explicit empirical-measure-at-D5 mandate WITHOUT pre-deciding revisit-threshold. Pattern: numeric thresholds in architect defaults get (a) rationale, (b) test-fixture validation, (c) production-measurement at smoke harness, (d) named revisit trigger in ADR — but NOT pre-committed re-tuning schedule (avoids over-engineering per Karpathy P2). PROMOTE-on-2nd-instance.

## Compliance attestation (S370 architect session)

- AP-1 ✓ (fresh-context dispatch per dispatch brief)
- AP-5 ✓ (re-read all binding sources per VBW; 30 source files read empirically; no memory-based authoring)
- AP-7 ✓ (every DEFER decision in § A.3 + § J + § N names prerequisites + revisit triggers — 17 OUT-of-scope + 10 RMs + Phase E DONE projection all with named triggers)
- AP-23 ✓ (first-instance HOLD discipline for 3 candidate lessons L-S370-1/2/3; no refinement-of-rule iterations)
- harness_priority_one ✓ (3 harness gaps surfaced — L-S354-2 + L-S366-4 + L-S369-1 — all carry-forward to next harness-stabilization sweep; explicitly NOT fixed here per hard_rules)
- D-060 ✓ (architect has no Bash; main commits per pre-dispatch-architect-commit-guard.sh hook)
- 0 charter writes / 0 constitution writes / 0 production code / 0 human-workspace writes
- I-S1 ✓ + I-S2 ✓ + I-S22 ✓ + I-S34 ✓ + I-S35 ✓ (all promoted in plan; none violated)
- 5-source-evidence chain 25 citations per § H
- Phase 1b CONSUMED with n=3 precedent per § A.4 (cold-start window CLOSED)
- 8 DD + 5 D + 33 DC + 10 AQ + 10 RM + § M Rule 17 GATE + § N Phase E DONE attestation per plan-025 contract

## Recommendation

**RATIFY** sub-plan 032 + dispatch S371 sandwich-dev FOCUSED_IMPL (~100-150K Opus budget per recalibrated CLAUDE.md table; n=3 precedent supports envelope; lower-band possible due to simpler shape). Phase E DONE attestation triggers post-S372 verifier PASS → Phase F-prime master-plan dispatch unblocked per § N + parent plan-028 § M.1.
