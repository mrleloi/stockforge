---
id: D-014-track-F-architecture
title: Track F architecture — BC-8 Analysis 3-perspective thesis pipeline (Phase 2)
date: 2026-05-01
status: ACCEPTED
level: ARCH

author:
  - "Claude Opus 4.7"
  - session: S41 (sandwich-architect subagent)

source_evidence:
  - path: agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md
    section: "S41 — Track F PLAN (BC-8 Architect); S42 — Track F IMPL; S43a — Track F UI + 5-Thesis Dogfood"
    quote: "Author Phase 2 Track F implementation spec; design BC-8 Analysis aggregate; design 3 perspective-agent system_prompts grounded per spec 001 § B.5; design LLM-port + cost-tracker-port architecture; design Streamlit page wireframe."
  - path: specs/tier2-feature/001-validate-investment-thesis.md
    section: "§ B.3 Key Use Case Implementation + § B.5 Phase 1 Bear/Bull Agents + § B.10 Cost Profile"
    quote: "Bear agent: ~20K tokens (Sonnet) = $0.10 / Bull agent: ~20K tokens (Sonnet) = $0.10 / Quant agent: ~25K tokens (Opus for reliability) = $0.70 / Synthesizer: ~15K tokens (Opus) = $0.40 / Target: ~$1.30 average, <$3 ceiling"
  - path: agent-workspace/constitution/invariants.md
    section: "I-S1 (no LLM math) + I-S10 (bear case ≥3) + I-S11 (multi-perspective) + I-S12 (disagreement preserved) + I-S35 (research-aid framing) + I-40 (cost cap)"
  - path: agent-workspace/memory/personal-risk-profile.md
    section: "Template — 33 USER FILL placeholders unfilled as of S30 close"
  - path: agent-workspace/memory/thesis-log/2026-04-30-VHM-exemplar.md
    section: "15 SQL queries Q1-Q15 pattern; recommendation PASS on Tier-1-only data"
  - path: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md
    section: "Authored same-session as this ADR; binding spec for S42-S43a"

related_user_prompt: SessionStart hook auto-resume (S41 entry per master-plan 005 § S41; user "continue" 2026-05-01 establishing Track F architect)

binding_phase: 2 (Phase 2 IMPL — Track F; binds S42 + S43a; supersedes spec 001 § B.5 sketch with concrete production design)

intent_classification:
  primary_intent: SCOPE
  affects_charter: false
  affects_scope: true
  urgency: NORMAL
  complexity_score: 70

options_considered:
  - id: A
    summary: 3 perspectives parallel asyncio.gather + Phase1Synthesizer Opus (per spec 001 verbatim)
    pros: [matches spec 001, fastest wall-clock, lowest review surprise]
    cons: [highest cost ~$1.30/thesis if Quant on Opus]
  - id: B
    summary: 3 perspectives sequential (cheaper retry budgeting per agent)
    pros: [easier per-agent budget enforcement, simpler debug]
    cons: [3x wall-clock breaches AC-1 5-min target on slow context]
  - id: C
    summary: 6 perspectives now (Macro/Behavior/Manager via stub or rule-based heuristic)
    pros: [satisfies I-S11 ≥4 strictly; no Phase-3 lift]
    cons: [doubles cost; Phase-3 BCs not ready; speculative scaffolding violates P2]

chosen: A
chosen_rationale: |
  Option A matches spec 001 § B.3 + § B.10 verbatim; preserves Phase 1 doctrine
  (3 perspectives + heuristic confidence + I-S11 documented exception per BR-8).
  Parallel asyncio.gather brings wall-clock under AC-1 5-min target. Cost target
  $1.30 average / $3 hard cap (BR-6 / I-40). Quant agent on Opus per spec 001
  reliability premium — flagged as SCOPE-tier user-gate in § Open Questions
  with Sonnet fallback path documented (saves $0.50/thesis but risks numeric
  interpretation drift). Option B rejected on wall-clock; Option C rejected
  on speculative scaffolding (P2) + Phase 3 BCs not ready.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-01
    via: S41 sandwich-architect subagent dispatch (master-plan 005 § S41)
  - actor: agent
    action: ACCEPTED
    at: 2026-05-01
    via: ARCH-tier autonomous-mode self-decide (per autonomous-protocol; SCOPE sub-questions flagged for user-gate explicitly in § Open Questions)

verified_by:
  - mechanism: pre-flight-VBW
    at: 2026-05-01
    result: PASS
  - mechanism: spec 006 cross-check
    at: 2026-05-01
    result: PASS

affects:
  charter: false
  spec_files:
    - specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md (NEW S41)
    - specs/tier2-feature/001-validate-investment-thesis.md (Phase 1 spec; Phase 2 implements its `Phase1*` symbols)
  code_paths:
    - packages/domain/analysis/**          # NEW S42
    - packages/application/analysis/**     # NEW S42
    - packages/infrastructure/analysis/**  # NEW S42
    - packages/contracts/events/thesis_recorded.py   # NEW S42
    - apps/dashboard/**                    # NEW S43a (first frontend)
    - apps/cli/validate_thesis.py          # NEW S43a
    - agent-workspace/memory/thesis-log/2026-MM-DD-{TICKER}.md × 5  # NEW S43a real thesis
  config_files: [pyproject.toml]   # streamlit pin
  other_decisions:
    - D-011 (Phase 2 entry SCOPE)
    - D-013 (S35 meta-loop-recovery promote-routing — distinct ADR; Track F is unrelated)

depends_on: [D-011, D-009, IMPL-S28-1]
supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  N/A — accepted at S41; binding through S42 + S43a + S43 verifier.

tags: [phase-2, track-F, BC-8-analysis, thesis-pipeline, sandwich-architect-S41]
---

# Decision D-014 — Track F Architecture (BC-8 Analysis Thesis Pipeline)

## Context

Phase 2 master-plan § S41 dispatches sandwich-architect to author Track F implementation spec. Phase 1 closed S30 with BC-8 empty (VHM exemplar was hand-authored, not machine-produced). Tracks A-D (S32-S36) shipped Tier 1+2 substrate (BC-1 dual-source dual-VN30, BC-2 fundamental + ratios, BC-5 news + LLM extractor). Track F (S41-S43a) ships first production LLM call path inside BC-8 + first Streamlit UI page + 5 REAL dogfood thesis (Charter Month-3 SC-3 + SC-4).

## Analysis

Three orthogonal architectural axes:

1. **Perspective concurrency** — sequential vs parallel; spec 001 § B.3 explicit `asyncio.gather` parallel
2. **Perspective count** — Phase 1 doctrine = 3 (Bear / Bull / Quant) per BR-8 documented I-S11 exception; full I-S11 ≥4 deferred Phase 3
3. **Synthesizer + Quant model** — Opus for reliability (numeric interpretation, disagreement detection) per spec 001 § B.10; Sonnet alternate halves cost but risks drift

Cross-cutting concerns:
- Cost tracking via `CostTrackerPort` (application-layer Protocol; SQLite-backed in-process impl Phase 2; future Postgres/Redis Phase 4+)
- Reproducibility via `temperature=0` + `prompt_hash` + deterministic `thesis_id = sha256(model_id + prompt_hash + ticker + as_of + data_md5)`
- Disagreement preservation enforced by `Synthesis.__post_init__` invariant — never collapse to HOLD per I-S12
- Bear case ≥3 distinct points + ≥3 distinct categories enforced by `Thesis._enforce_bear_case()` per I-S10

## Decision

**Track F ships per spec 006 with 3-perspective parallel architecture matching spec 001 § B.3 verbatim:**

- BC-8 domain: `Thesis` aggregate (root) + `PerspectiveAnalysis` + `Synthesis` entities; `TradeOffMatrix` + `GroundedPoint` + `Recommendation` + `ConfidenceLevel` + `Conviction` + `BearCategory` value objects (StrEnum)
- Application: `ValidateThesisPhase1UseCase` + `LLMPerspectivePort` + `CostTrackerPort` + `ThesisRepository` Protocol
- Infrastructure: `BearPerspectiveAgent` + `BullPerspectiveAgent` + `QuantPerspectiveAgent` (concrete `LLMPerspectivePort` impls) + `Phase1Synthesizer` + `ClaudeLLMPerspectiveAdapter` (Anthropic SDK; reuse `claude_llm_extractor.py` S36 patterns) + `Phase1DataGatherer` (orchestrates BC-1 + BC-2 + BC-5 reads) + `SqliteThesisRepository` + `InProcessCostTracker`
- Cross-BC contract: `ThesisRecorded` event in `packages/contracts/events/thesis_recorded.py`
- UI: Streamlit page `apps/dashboard/pages/validate_thesis.py` + CLI fallback `apps/cli/validate_thesis.py`

**Models defaults (recommended; user may override SCOPE-tier per § Open Questions):**
- Bear: `claude-sonnet-4-6` ($0.10/run target)
- Bull: `claude-sonnet-4-6` ($0.10/run target)
- Quant: `claude-opus-4-7` ($0.70/run target) — Opus for numeric-discipline reliability
- Synthesizer: `claude-opus-4-7` ($0.40/run target)
- All `temperature=0` for reproducibility AC-5

**Cost envelope:**
- Target average: $1.30 per validation
- Hard cap: $3.00 per validation (I-40 + spec 001 AC-1)
- 5-thesis dogfood S43a: ≤$15 total; session hard-cap $20

**Phase split projection (S42):** ~16 files. If pre-flight projects >230K context at S42 entry, split into S42a (domain + ports + use case) + S42b (adapters + repository + events) per master-plan §S42 line 549 split-doctrine.

### What this means concretely

- BC-8 first ever production aggregate ships at S42; S43a wires UI + dogfood
- 3-perspective Phase-1 doctrine preserved (BR-8 documented I-S11 exception)
- Personal-risk-profile.md unfilled → Quant agent context defaults to charter-floor (15% / 30%); IMPL-S41-N deviation if user does not fill before S43a dogfood
- LLM-math creep grep target: 0 hits in `packages/{domain,application,infrastructure}/analysis/`
- Live LLM never in CI; tests use `MockLLMPerspectivePort` fixtures
- Streamlit Phase 2; FastAPI deferred Phase 4+ (single-user self-use binds Phase 2)

## Why (Reasons)

1. **Spec fidelity** — spec 001 § B.3 + § B.5 + § B.10 already Phase-1-locked; Phase 2 lifts to production without re-architecture (P2 Simplicity)
2. **I-S10 / I-S12 / I-S35 enforcement at aggregate boundary** — `Thesis.__post_init__` + `Synthesis.__post_init__` raise on violation; no LLM bypass possible (Charter Principle 3 Adversarial)
3. **Cost discipline** — `CostTrackerPort` + scoped budget context manager + per-perspective sub-budget; matches spec 001 § B.10 + I-40
4. **Reproducibility AC-5** — `temperature=0` + `prompt_hash` + sha256 thesis_id; auditable
5. **Phase 3 readiness** — `PerspectiveRole` enum has 6 values (3 Phase 2 + 3 Phase 3 stubs `deferred=True`); when Phase 3 BCs (Macro / Crowd / Influence) ship, perspectives plug in without aggregate refactor

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| **Personal-risk-profile.md unfilled** (33 USER FILL placeholders as of S30 close) | HIGH | S41 surfaces P0 prerequisite; default = charter-floor (15% / 30%) + document IMPL-S41-N deviation; pending_user_gate flag in § Open Questions |
| Bear retry loop blowing cost cap | MED | Hard retry cap 1× per agent; if still <3 categories → `Thesis.incomplete()`; cost stops |
| LLM hallucinates source_url | HIGH | `GroundedPoint.__post_init__` non-empty validate + post-LLM validator strips ungrounded claims + S43 verifier spot-checks |
| Disagreement detection too aggressive (every thesis disagrees) | LOW | Threshold = "opposite verdict + both ≥MODERATE conviction"; calibrate at S43a |
| Disagreement detection too weak (no thesis disagrees = prompt drift) | MED | VF-5 acceptance: ≥1 of 5 dogfood must show disagreement; otherwise prompt iteration |
| Quant agent computes in prose despite system prompt | HIGH | Verifier S43 grep `r"approximately\|around\|roughly\|~ \d+%"` 0 hits required; banned-phrase list in § B.5.3; tool-call schema forces structured numeric |
| Streamlit Vietnamese diacritic rendering | LOW | UTF-8 default + fixture with Vietnamese excerpt; pin Streamlit ≥1.32 |
| Re-run reproducibility violated | MED | `temperature=0` + `prompt_hash` recorded; thesis_id deterministic; S43a re-runs 1 of 5 to verify |
| Cost tracker race in parallel agents | LOW | `asyncio.Lock` in `InProcessCostTracker`; per-call atomic add |
| 16-file MULTI at S42 budget overrun | MED | Pre-flight projection at S42 entry; split S42a + S42b if >230K (master-plan §S42 doctrine) |
| **SCOPE-tier user-gate stalls** (Quant model + risk-profile fill) | MED | Recommend defaults explicitly; proceed autonomously if user defers; document IMPL-S41-N |

## Open Questions (SCOPE-tier — RESOLVED 2026-05-01 via in-session AskUserQuestion at S43a entry)

> Both flagged for explicit user pick per Q-B2 doctrine. **Both resolved 2026-05-01** at S43a entry via in-session `AskUserQuestion`. `pending_user_gate: false` for both.

### Q-S41-1 — QuantAgent model: Opus vs Sonnet? — **RESOLVED**

- **Option A**: `claude-opus-4-7` — $0.70/run; reliability premium; total $1.30/thesis avg (was Recommended)
- **Option B**: `claude-sonnet-4-6` — $0.20/run; saves $0.50/thesis
- **Option C** (USER PICK 2026-05-01): **Opus 4.7 for first 5 dogfood theses; reassess at Phase 2 close** — costs ~$1.50/thesis × 5 = ~$7.50; switch decision deferred until structured-output adherence observed

**User answer**: **C**. S43a-DOGFOOD wires `claude-opus-4-7` for QuantAgent across all 5 theses. Phase 2 close adds carryover: "Quant model post-dogfood reassess (C → A or B per observed adherence)". `pending_user_gate: false`.

### Q-S41-2 — personal-risk-profile.md fill timing? — **RESOLVED**

- **Option A** (USER PICK 2026-05-01; was Recommended): **Proceed with charter-floor defaults** (max_position 0.15 / sector 0.30 / max_drawdown 0.20). Fill profile post-dogfood once seeing concrete examples ("fill informed by exemplars" doctrine).
- **Option B**: Block until user fills.
- **Option C**: Fill inline.

**User answer**: **A**. S43a-DOGFOOD proceeds without unfilled-profile blocker; Quant agents receive charter-floor risk context for all 5 theses. Post-dogfood: surface fill prompt with exemplars as context. `pending_user_gate: false`.

## Amendments (append-only)

> N/A as of 2026-05-01.

## Acceptance Record

- **2026-05-01**: PROPOSED + ACCEPTED by Claude Opus 4.7 (S41 sandwich-architect subagent dispatch) via ARCH-tier autonomous-mode self-decide; 2 SCOPE sub-questions flagged for user explicit-pick in § Open Questions
