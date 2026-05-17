---
observation_id: sandwich-architect-S367-phase-e3-extraction-plan
type: sandwich-architect-output
architect_agent_id: (this fresh-context dispatch; see dispatch.jsonl for ID)
created_at: 2026-05-17
plan_authored: agent-workspace/session-plans/pending/031-S367-phase-e3-claim-extraction-wrapper.md
target_session: S368 (dev FOCUSED_IMPL) + S369 (verifier AP-1)
verifier_session: S369 sandwich-verifier AP-1 (fresh-context post-S368 dev close)
phase_milestone: E.3 Vietnamese Claim Extraction Wrapper — THIRD sub-plan of Phase E master plan-028 (per § E sequencing)
sandwich_architect_has_no_Bash_tool: true (Read/Glob/Grep/Write only per agent template line 5; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
phase_1b_self_calibration: CONSUMED with n=2 vietnamese-nlp-impl precedent (S362 + S365 both clean Sonnet IMPL cycles ~150-160K / ~39min / 0 mistakes); cold-start window NARROW but EXISTING; AUGMENT shape inherits cleanly from adapter-wiring portion of precedent
plan_type: FOCUSED_IMPL sub-plan (5 sub-tracks D1-D5; third of 4 sub-themes per parent master plan-028 § E decomposition)
parent_plan: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md (PHASE-MASTER-PLAN; sub-plan 031 satisfies its § E.3 contract per DD-5 EXISTING-EXTRACTOR-AUGMENT + AQ-6 anthropic_api_to_subagent IN-SCOPE)
predecessor_sub_plans: [029-S361-phase-e1-vn-tokenization SHIPPED+VERIFIED, 030-S364-phase-e2-vn-sentiment-lexicon SHIPPED+(S366 VERIFY pending non-blocking)]
related_adrs: [D-050-S227-anthropic-to-subagent-systemic ACCEPTED CHARTER 2026-05-09 (this plan CLOSES § Deferred D-051), D-070 pyvi VN tokenizer, D-071 VN sentiment lexicon UNCALIBRATED-V0, D-072 PROPOSED-AT-IMPL via this plan D4]
---

# S367 sandwich-architect — Phase E.3 VN Claim Extraction Wrapper sub-plan-031 authoring observation

## What was authored

`agent-workspace/session-plans/pending/031-S367-phase-e3-claim-extraction-wrapper.md` — FOCUSED_IMPL sub-plan for Phase E sub-theme E.3 VN Claim Extraction Wrapper, decomposing into 5 sub-tracks (D1 ExtractedClaim NEW fields + D2 ClaudeLlmExtractor AUGMENT + D3 unit test extensions + D4 ADR D-072 + D5 integration smoke CLI) with EXISTING-EXTRACTOR-AUGMENT STEP 0 pattern (per parent plan-028 DD-5) bundled with anthropic→subagent transport-flip closure (per D-050 § Deferred D-051) gated by CHARTER-TIER GATE STOP-AND-ASK for claude CLI substrate availability + Rule 16 mode-2 LLM-output drift (per dispatch brief + parent plan-028 § K.2 anticipated FLAGS).

**Plan stats** (architect-internal):
- Total LOC: ~1085 (within 150-230K Opus PLAN budget; well-grounded in 35 VBW-read source files)
- 7 DD architecture decisions (DD-1..DD-7) all pre-answered with rationale + adversarial alternates
- 5 sub-tracks D1-D5 in § E with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract
- 33 DC DoD items (≥25 floor satisfied)
- 10 AQ pre-answered (AQ-1..AQ-10)
- 5-source-evidence chain (5 decisions × 5 sources = 25 citations) in § H
- 8 RM entries (RM1..RM8) with mitigation in § J
- **STEP 0 STOP-AND-ASK trigger inventory** with 4 documented triggers (2 CHARTER-TIER + 2 TACTICAL-TIER; per AP-7 anti-vacuous-defer + Karpathy P1 think-before-coding)
- **§ M CHARTER-TIER GATE clause** as canonical reference for S368 dev (2 CHARTER-TIER triggers + 1 NON-BLOCKING carry-forward from sub-plan 030)
- **§ L Conditional next-step** with 4 branches L.1-L.4 covering all post-gate paths

## Key architectural decisions (DD-1..DD-7 summary)

| DD | Decision | Pre-decided or CONDITIONAL? |
|---|---|---|
| **DD-1** | **EXISTING-EXTRACTOR-AUGMENT (NOT parallel VnClaudeExtractor class)** | PRE-DECIDED per parent plan-028 DD-5 + L-S345-3 single-helper-with-keyword-only-flag precedent |
| **DD-2** | **Transport default FLIPPED from `_default_transport` to `make_claude_cli_news_transport()` factory** | PRE-DECIDED per D-050 SYSTEMIC + user memory rule `anthropic_api_to_subagent` (verbatim 2026-05-09) + D-050 § Deferred D-051 closure mandate; CONDITIONAL only on STEP 0.3 claude CLI substrate availability gate |
| **DD-3** | **ExtractedClaim NEW fields = `lexicon_score: float` + `mentioned_pump_anchors: tuple[str, ...]`** | PRE-DECIDED per parent plan-028 DD-5 step 4 + 5 explicit field-add mandate |
| **DD-4** | **Rule 16 mode 2 satisfaction = DETERMINISTIC-PIPELINE ECHO for new fields (NOT LLM-emitted)** | PRE-DECIDED per Rule 16 mode 2 + I-S1 + parent DD-5 step 4 explicit "Rule 16 mode 2 deterministic-echo" |
| **DD-5** | **Tokenizer DI = PRE-LLM PROMPT HINT (NOT body transformation; opt-in via tokenizer type-check)** | PRE-DECIDED per Karpathy P2 simplicity + Rule 6 verbatim quote preservation; architect-judgement refinement of parent DD-5 step 2 |
| **DD-6** | **ADR D-072 PROPOSED-AT-IMPL records AUGMENT + transport-flip + new fields + DI graceful-degradation** | PRE-DECIDED per severity-schema IMPL-tier auto-ratification + AP-7 anti-vacuous-defer + D-050 → D-051 closure traceability |
| **DD-7** | **Existing `claude_cli_news_transport.py` UNCHANGED — adopted verbatim per DD-7** | PRE-DECIDED per Karpathy P3 surgical-changes + already-shipped per D-050 § Deferred D-051 |

**Single most important callout**: **DD-2 + DD-6 are the D-051 deferral closure** — D-050 ACCEPTED CHARTER 2026-05-09 explicitly listed D-051 in § Follow-ups (news-extractor refactor). THIS sub-plan IS D-051 closure (transport flip + import removal in news-extractor surface). D-052 (pyproject dep removal) remains deferred per § A.3 + AQ-9 + RM5 (scope-narrowing rationale).

## Phase 1b self-calibration (CONSUMED variant; n=2 vietnamese-nlp-impl PRECEDENT; cold-start window NARROW)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash; 35 files cited in plan § A.4):

Highlights:
1. `agent-workspace/memory/.planner-stats.tsv` (header-only confirmed; L-S354-2 + L-S366-4 carry-forward)
2. `agent-workspace/memory/current-execution.md` (S365 row L147-168 confirms n=1 + S362 row L172-188 confirms n=0 → n=2 precedent; both Sonnet IMPL clean cycles)
3. `agent-workspace/memory/decisions/050-S227-anthropic-to-subagent-systemic.md` (172 LOC; CHARTER ACCEPTED 2026-05-09; § Deferred D-051 = THIS plan closure target)
4. `~/.ccs/instances/.../anthropic_api_to_subagent.md` (24 LOC; user memory rule verbatim 2026-05-09 SYSTEMIC)
5. `packages/infrastructure/news/claude_llm_extractor.py` (226 LOC; modification target; `_default_transport` L80-99 + `import anthropic` L84 + `transport` field L112 + `_build_claim` L159-218)
6. `packages/infrastructure/news/claude_cli_news_transport.py` (173 LOC; SHIPPED per D-050 § Deferred D-051; `make_claude_cli_news_transport()` factory L158-173 = drop-in replacement; ADOPTED VERBATIM per DD-7)
7. `packages/domain/news/models/extracted_claim.py` (83 LOC; modification target for D1 NEW FIELDS)
8. `apps/extraction/sentiment/vn_lexicon.py` + `__init__.py` (per S365 row + DI exports confirmed)
9. `packages/infrastructure/nlp/vn_tokenizer.py` (148 LOC; DI source for D2)
10. Grep `import anthropic|from anthropic|ANTHROPIC_API_KEY` across repo (30 matches; 1 production site at claude_llm_extractor.py:84 = removal target; clean DI substrate elsewhere)

**Calibration parameters extracted**:
- **task_class**: `vietnamese-nlp-impl` (PRECEDENT n=2 from S362 + S365)
- **sample_size**: **2** (S362 ~159K Sonnet / ~39min / 1053/1053 tests / 0 mistakes; S365 ~150K Sonnet / ~39min / 1079/1079 tests / 0 mistakes)
- **Cold-start?**: **NO for vietnamese-nlp-impl task-class** (n=2 precedent narrow-but-growing); **NO for AUGMENT-pattern adapter+tests+CLI shape** (transfers cleanly from S362+S365); **PARTIAL-COLD-START for transport-flip-as-default shape** (sub-component novel; never previously default-shipped per D-051 deferral)
- **Adjustment to default budget**: NONE for augment+tests portion (mirror S362+S365 ~150-160K); +10-20K Opus reserve for transport-flip smoke + STEP 0 anthropic-SDK-retention pre-check (CHARTER-TIER GATE risk LIKELY-VERY-LOW per RM2; non-firing default)

**S368 DEV BUDGET PROJECTION**: 100-150K Opus FOCUSED_IMPL per recalibrated CLAUDE.md table (per dispatch brief: sandwich-dev back on Opus); typical 90-130K; full 150K cap respected.

## What was NOT included (deliberately deferred)

Per § A.3 (13 OOS items each with revisit trigger):

1. **Sub-theme E.4 ticker resolver** — separate sub-plan 032; E.3 doesn't modify ticker-resolution path
2. **D-052 anthropic-dep removal from pyproject.toml** — separate cleanup ADR per D-050 § Deferred; THIS sub-plan removes only SDK-import not dep
3. **LLM-generated lexicon_score / mentioned_pump_anchors** — would violate I-S1 + Rule 16 mode 1; deferred via STEP 0.4 STOP-AND-ASK trigger (b)
4. **EchoValidator runtime tier enforcement** — Rule 16 § Enforcement runtime; not applicable to post-LLM deterministic computation pattern
5. **Lexicon-score / tokenizer-output caching** — Karpathy P2 simplicity; latency negligible at v0
6. **ExtractedClaim persistence schema migration** — backward-compat via dataclass field defaults
7. **Multi-perspective claim extraction** — Phase F-prime BC-8 separate scope
8. **LLM model upgrade Sonnet→Opus** — separate decision with own cost/quality trade-off
9. **Prompt caching at adapter** — Phase 3 production-throughput gate
10. **Streaming response handling** — Phase 3 production-throughput gate
11. **Negation handling at lexicon-score** — sub-plan 030 RM10 carry-forward; v0.CALIBRATED cycle
12. **ExtractedClaim-field-determinism check hook** — harness-stabilization sweep; AP-23 2+ instance trigger
13. **Charter amendment SHIP for anthropic SDK retention reversal** — STOP-FINDING file only; main session ratifies via AskUserQuestion

## STEP 0 STOP-AND-ASK trigger inventory (4 documented)

Dispatch brief specified 2 triggers (anthropic SDK retention rejection + existing extractor entanglement). Architect SPLITS/REFINES to 4 + maps:

1. **(a) CHARTER-TIER — claude CLI substrate unavailable** (STEP 0.3; inverse of "anthropic SDK retention" — if claude CLI fails, anthropic SDK might be retained as fallback per D-050 § Edge cases)
2. **(b) CHARTER-TIER — Rule 16 mode-2 LLM-output drift** (STEP 0.4; per parent § K.2 sub-plan 031 anticipated FLAG (b))
3. **(c) TACTICAL — extractor pipeline non-determinism** (STEP 0.5; AP-7 architect-added)
4. **(d) TACTICAL — dogfood extraction failure** (STEP 0.5; AP-7 architect-added)

Also documented: **corpus-labelling source carry-forward from sub-plan 030 STOP-FINDING-S365 is NON-BLOCKING** for E.3 per parent AQ-8 + dispatch brief constraint — UNCALIBRATED-V0 lexicon is usable for hint emission; calibration cycle is data-only update at sub-plan 030-V2 (NOT sub-plan 031 work).

## Plan author lessons / mini-postmortem

**Pleasantly surprised**:
- `claude_cli_news_transport.py` already-shipped + production-ready per D-050 § Deferred D-051 closure (173 LOC; clean factory pattern) — significantly de-risks D2 transport-flip; treated as ADOPTED VERBATIM per DD-7
- D-050 ACCEPTED 2026-05-09 already established CHARTER-tier rule with explicit follow-up pointers (D-051 + D-052) — THIS sub-plan executes D-051 cleanly per established chain
- VnSentimentLexicon (sub-plan 030) exports VN_CULTURAL_ANCHORS frozenset specifically for E.3 consumer (per sub-plan 030 D2 forward-design); excellent dependency hygiene
- ExtractedClaim frozen+slots dataclass + field defaults pattern preserves backward-compat by construction for D1 NEW fields — zero risk of existing-test breakage from schema additions

**Concerns surfaced**:
- **Lexicon coverage on production extraction unknown** until sub-plan 030 calibration cycle ships (per sub-plan 030 RM4 + UNCALIBRATED-V0); ADR D-072 § Revisit trigger 3 explicit — "Lexicon coverage <50% on production extraction → triggers sub-plan 030-V2 calibration cycle per ADR D-071 revisit trigger 1"
- **Claude CLI substrate availability in CI environments** — likely NOT installed in CI; D5 dogfood smoke degrades to mock LLM via `--stub-transport` flag (per AQ-6 + RM2 mitigation)
- **D-052 anthropic-dep removal still deferred** — user may consider D-050 compliance incomplete until pyproject.toml dep removed; this sub-plan scope-narrows per AQ-9 + RM5; verifier S369 acknowledges but doesn't flag as defect
- **Lexicon DI graceful-degradation default = lexicon=None** — existing CLI consumers get lexicon_score=0.0 + mentioned_pump_anchors=() until they wire production lexicon explicitly; PRO: backward-compat; CON: most production extractions in interim won't have lexicon-driven enrichment (acceptable per parent DD-5 step 3 "production injection = E.2's calibrated lexicon")

**Pattern reusable for sub-plan 032 (E.4 ticker resolver)**:
- Same AUGMENT-of-ClaudeLlmExtractor pattern at `_build_claim` (sub-plan 032 modifies L177-180 2-4 char uppercase filter per parent DD-6)
- Same DI-with-defaults graceful-degradation pattern
- Same Rule 16 mode 2 deterministic-pipeline-echo pattern for `resolution_confidence: float` (sub-plan 032 new field per parent DD-6 step 3)
- Same STEP 0 STOP-AND-ASK pattern for ambiguous mapping CHARTER-TIER GATE (per parent § K.2 sub-plan 032 anticipated FLAG NEW Rule 17)

## Phase 1b refinement candidates (architect-internal; for next architect dispatch)

1. **L-S367-1 PRESERVE**: Per current-execution.md auto-populated tracking — sub-plan 030 + 031 + 032 + future Phase E sub-plans all use SAME `vietnamese-nlp-impl` task_class; planner-stats infrastructure gap (L-S354-2 + L-S366-4 carry-forward) means each architect dispatch reads sessions-rollup MANUALLY; consider promoting to skill the "Phase 1b cold-start via current-execution-row-grep" pattern at AP-23 2nd-instance trigger (sub-plan 030 was first instance; sub-plan 031 IS second instance — PROMOTE candidate per AP-23)

2. **L-S367-2 PRESERVE**: D-050 → D-051 → D-052 ADR-deferral-chain-closure pattern (sub-plan IMPL closes a previously-deferred ADR) is novel for stockforge; architect-judgement to defer D-052 separately per scope-narrowing rationale is REUSABLE — when an IMPL touches an ADR-deferred surface, scope-narrowing (close 1-of-N deferrals, leave rest) is preferred to scope-creep (close all deferrals in one shot); first instance HOLD per AP-23

3. **L-S367-3 NEW PATTERN**: DI-graceful-degradation-with-type-check-opt-in (DD-5 `isinstance(self.tokenizer, VnTokenizer)` gating prompt hint) is novel; architect-judgement: AP-23 first-instance HOLD; 2nd instance trigger = sub-plan 032 ticker resolver DI pattern (if uses same opt-in)

## Process notes (compliance attestation)

- Started session by reading dispatch brief 2026-05-17 in full
- Read parent plan-028 in 3 chunks (file >25K tokens); confirmed § E.3 row + DD-5 + AQ-6 + § K.2 sub-plan 031 anticipated FLAGS
- Read precedent sub-plans 029 + 030 in 3 chunks each; confirmed structure template + § L conditional + § M CHARTER-TIER GATE + § N attestation patterns
- Read ADR D-050 in full (172 LOC); confirmed D-051 deferral target + D-052 deferral scope
- Read user memory rule `anthropic_api_to_subagent.md` (24 LOC); confirmed verbatim 2026-05-09 directive SYSTEMIC
- VBW-verified existing ClaudeLlmExtractor + claude_cli_news_transport substrate (both already-shipped); D-051 closure path mechanically simple per DD-2 + DD-7
- VBW-verified ExtractedClaim + ExtractorMetadata + Sentiment + VnSentimentLexicon + VnTokenizer DI substrate (all instantiable per current-execution.md S362+S365 rows)
- Grep-verified anthropic SDK presence: 30 matches across repo; 1 production site at claude_llm_extractor.py:84 = removal target; 0 sites elsewhere in news-extractor surface (analysis-extractor already at zero per S227 D-050 close); pyproject.toml dep retained (D-052 separate scope)
- Authored sub-plan 031 (1085 LOC) + THIS observation (~210 LOC); both within agent-workspace/ write surface (no charter/constitution/human-workspace writes)
- Architect has [Read, Glob, Grep, Write] tools; NO Bash; main session commits per D-060 + pre-dispatch-architect-commit-guard.sh

**Total architect dispatch budget consumed**: ~180-200K Opus PLAN (within 150-230K envelope per recalibrated CLAUDE.md table; 3rd opportunity validating M-S360-2 empirical ratification)

---

**END OF S367 SANDWICH-ARCHITECT OBSERVATION**

> Architect output complete. Main session reviews + dispatches S368 sandwich-dev FOCUSED_IMPL per parent plan-028 § L sequencing + plan-031 § L.1 standard-path sequencing post-ratification.
