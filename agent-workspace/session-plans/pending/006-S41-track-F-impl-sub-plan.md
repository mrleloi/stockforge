---
plan_id: 006-S41-track-F-impl-sub-plan
session: S41
session_type: PLAN (sandwich-architect subagent output; binds S42 + S43a)
authored_at: 2026-05-01
authored_by: Claude Opus 4.7 (S41 sandwich-architect subagent dispatch)
predecessor: agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md § S41 (master-plan)
extends: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md (binding spec, same-session)
binding_decision: agent-workspace/memory/decisions/014-track-F-architecture.md (D-014; same-session)
budget_target: ~50-80K main + ~150K subagent dispatch (this PLAN was that subagent)
mode: AUTONOMOUS
---

# S41 Track F IMPL Sub-Plan — S42 + S43a

> **Goal**: Per-session deliverables matrix for S42 (Track F IMPL — BC-8 domain + adapters + use case) and S43a (Track F UI + 5-thesis dogfood). Mirror format of `004-S24-phase-1-thin-slice-plan.md`.
>
> **Binding spec**: `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md`
> **Binding ADR**: `agent-workspace/memory/decisions/014-track-F-architecture.md`
> **Binding master-plan**: `agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md` § S41 + § S42 + § S43a + § S43

---

## Critical Path

```
S41 (PLAN — this sub-plan + spec 006 + D-014)
  ↓
S42 (MULTI_TASK_IMPL — BC-8 domain + adapters + use case)
  ↓ [split S42a/S42b if pre-flight >230K]
S43a (FOCUSED_IMPL — Streamlit + CLI + 5-thesis dogfood)
  ↓
S43 (VERIFY — sandwich-verifier whole-Phase-2 + Track F V1-V10 + VF-1..VF-3)
```

S42 hard-deps on S41 deliverables (spec 006 + D-014). S43a hard-deps on S42 close. S43 hard-deps on S43a close.

---

## SCOPE-tier User-Gate Reminder (per D-014 § Open Questions)

Two flags for user explicit-pick before/at S42 entry:

- **Q-S41-1 QuantAgent model** — Opus (Recommended; $0.70/run) vs Sonnet ($0.20/run). Default Opus per spec 001 § B.10. `pending_user_gate: true`.
- **Q-S41-2 personal-risk-profile.md fill timing** — A=Proceed charter-floor (Recommended; non-blocking) / B=Block S42 until user fills / C=AskUserQuestion 1Q. Default A. `pending_user_gate: true`.

If user does not respond by S42 entry → proceed with Recommended defaults; document IMPL-S42-N deviation if needed.

---

## S42 — Track F IMPL (BC-8 Domain + Adapters + Use Case)

### Meta

| Field | Value |
|---|---|
| Session type | MULTI_TASK_IMPL |
| Agent | main (Dev half of sandwich; S43 Verifier closes) |
| Budget envelope | ~200-240K (under 250K MULTI cap; pre-flight projection at S42 entry mandatory) |
| Predecessor | S41 (this plan + spec 006 + D-014) |
| Successor | S43a |
| Decision tier | IMPL — per D-014 chosen Option A; entity field choices + adapter implementation IMPL-tier per D-003 doctrine |
| Split doctrine | If pre-flight projects >230K, split S42a (domain + ports + use case) / S42b (adapters + repository + events + tests) per master-plan §S42 line 549 + Phase 1 plan R1 doctrine |

### Goal

Ship BC-8 Analysis production code: domain entities + value objects (~7 files) + application layer (use case + 2 ports + repository Protocol; ~4 files) + infrastructure (3 perspective agents + synthesizer + data-gatherer + Claude LLM adapter + SQLite repo + cost tracker; ~7 files) + cross-BC event (1 file) + tests (~6 test files; ≥40 PASS) per spec 006 § B.2-B.10. All LLM calls mocked in CI.

### Pre-flight reads (≤5 files)

1. `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md` (S41 spec — binding)
2. `agent-workspace/memory/decisions/014-track-F-architecture.md` (S41 ADR — binding)
3. `packages/domain/news/models/extracted_claim.py` + `packages/infrastructure/news/claude_llm_extractor.py` (S36 BC-5 reference for LLM adapter patterns + provenance fields)
4. `packages/domain/fundamental/services/ratio_service.py` (S34 BC-2 reference for ratio compute integration)
5. `agent-workspace/constitution/architecture.md` § BC-8 + § Layer Hierarchy + § Cross-BC Rules

VBW pre-flight per L-S30-1 / BP-S30-1: `Glob` + `ls` each NEW directory before Write; verify no existing file at target path.

### Deliverables (~16 files; ~2,200 LOC; ≥40 tests)

**BC-8 Domain (`packages/domain/analysis/`):**
1. NEW `packages/domain/analysis/__init__.py` ≤30 LOC (barrel)
2. NEW `packages/domain/analysis/value_objects/__init__.py` ≤20 LOC + `recommendation.py` ≤25 LOC + `confidence_level.py` ≤25 LOC + `conviction.py` ≤25 LOC + `bear_category.py` ≤30 LOC (4 StrEnums)
3. NEW `packages/domain/analysis/value_objects/grounded_point.py` ≤80 LOC (frozen dataclass + `__post_init__` enforcing I-1 + Rule 6 ≤500-char)
4. NEW `packages/domain/analysis/value_objects/trade_off_matrix.py` ≤80 LOC (4 dimensions VALUE/QUALITY/GROWTH/RISK + DimensionVerdict + evidence map)
5. NEW `packages/domain/analysis/models/__init__.py` ≤15 LOC + `perspective_analysis.py` ≤90 LOC (PerspectiveRole 6-value StrEnum incl. Phase 3 stubs + frozen dataclass)
6. NEW `packages/domain/analysis/models/synthesis.py` ≤120 LOC (Confluence StrEnum + Disagreement frozen dataclass + Synthesis with `__post_init__` invariant — disagreement preserved per I-S12)
7. NEW `packages/domain/analysis/models/thesis.py` ≤180 LOC (ThesisStatus StrEnum + Thesis aggregate root + `_enforce_bear_case()` ≥3 distinct points + ≥3 distinct categories per I-S10 + `incomplete()` classmethod)
8. NEW `packages/domain/analysis/repositories/__init__.py` ≤10 LOC + `thesis_repository.py` ≤60 LOC (ThesisRepository Protocol; methods `save(thesis)`, `get_by_id(thesis_id)`, `find_by_ticker(ticker, as_of)`)

Domain LOC subtotal target: **~500 LOC across ~10 files**

**BC-8 Application (`packages/application/analysis/`):**
9. NEW `packages/application/analysis/__init__.py` ≤15 LOC
10. NEW `packages/application/analysis/ports/__init__.py` ≤10 LOC + `llm_perspective_port.py` ≤50 LOC (Protocol) + `cost_tracker_port.py` ≤70 LOC (Protocol + Budget context manager + CostBudgetExceeded exception)
11. NEW `packages/application/analysis/use_cases/__init__.py` ≤10 LOC + `validate_thesis_phase1.py` ≤180 LOC (per spec 006 § B.3 + spec 001 § B.3 verbatim adapt)

Application LOC subtotal target: **~300 LOC across ~3-4 files**

**BC-8 Infrastructure (`packages/infrastructure/analysis/`):**
12. NEW `packages/infrastructure/analysis/__init__.py` ≤15 LOC
13. NEW `packages/infrastructure/analysis/perspectives/__init__.py` ≤15 LOC + `bear_agent.py` ≤150 LOC + `bull_agent.py` ≤150 LOC + `quant_agent.py` ≤150 LOC (each implements LLMPerspectivePort; system_prompt verbatim from spec 006 § B.5.1/B.5.2/B.5.3)
14. NEW `packages/infrastructure/analysis/phase1_synthesizer.py` ≤200 LOC (Phase1Synthesizer per spec 001 § B.6 + I-S12 disagreement detection algorithm per spec 006 § A.11)
15. NEW `packages/infrastructure/analysis/phase1_data_gatherer.py` ≤150 LOC (per spec 006 § B.6 — orchestrates BC-1 BarRepository + BC-2 FundamentalRepository + RatioService + BC-5 NewsRepository + ClaimRepository)
16. NEW `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` ≤200 LOC (Anthropic SDK wrapper; reuse `claude_llm_extractor.py` patterns; temperature=0; prompt_hash recorded; tool-call schema for numeric interpretation)
17. NEW `packages/infrastructure/analysis/sqlite_thesis_repository.py` ≤180 LOC (implements ThesisRepository Protocol; theses table schema per spec 006 § A.6.2)
18. NEW `packages/infrastructure/analysis/in_process_cost_tracker.py` ≤80 LOC (CostTrackerPort impl; asyncio.Lock; scoped_budget context manager)

Infrastructure LOC subtotal target: **~1,200 LOC across ~9-10 files**

**Cross-BC Contracts:**
19. NEW `packages/contracts/events/thesis_recorded.py` ≤60 LOC (frozen dataclass per spec 006 § B.8)
20. EDIT `packages/contracts/events/__init__.py` (+5 LOC export)

**Tests:**
21. NEW `packages/domain/analysis/test_value_objects.py` ≤180 LOC (≥10 tests — GroundedPoint validation + TradeOffMatrix + StrEnum membership)
22. NEW `packages/domain/analysis/test_models.py` ≤220 LOC (≥15 tests — Thesis bear-case enforcement [<3 points raises, 3 same-category raises, 3 distinct categories passes], Synthesis disagreement invariant, PerspectiveAnalysis frozen)
23. NEW `packages/application/analysis/test_use_case.py` ≤180 LOC (≥10 tests — orchestration with MockLLMPerspectivePort fixture; happy path; bear retry; cost cap CostBudgetExceeded; reproducibility same input → same thesis_id)
24. NEW `packages/infrastructure/analysis/test_synthesizer.py` ≤120 LOC (≥6 tests — disagreement detection thresholds; opposite-conclusion preserved; INVESTIGATE recommendation when disagreement)
25. NEW `packages/infrastructure/analysis/test_repository.py` ≤100 LOC (≥5 tests — SQLite roundtrip + thesis_id PK + payload_json fidelity)
26. NEW `packages/contracts/test_thesis_recorded.py` ≤50 LOC (≥3 tests — frozen, eq+hash)

Tests LOC subtotal target: **~850 LOC across ~6 files; ≥49 tests (target ≥40 per master-plan)**

**Pyproject (if needed):** EDIT `pyproject.toml` only if Anthropic SDK version pin needs bump; reuse S36 dep.

**Total**: ~16-20 files NEW + 1-2 EDIT + ~2,200 LOC + ≥49 tests.

### Success Criteria (8 testable bullets per master-plan §S42)

- [ ] `pytest packages/domain/analysis/ packages/application/analysis/ packages/infrastructure/analysis/ packages/contracts/test_thesis_recorded.py` ≥40 PASS in <3s
- [ ] LLM port mocked in tests; NO live LLM in CI (grep `Anthropic\|anthropic.Anthropic\(` in tests → 0 hits)
- [ ] Bear case validation enforced — pytest constructs Thesis with 2-point bear case, expects `BearCaseInvariantError`; constructs 3 same-category, expects `BearCaseInvariantError`; 3 distinct categories passes
- [ ] Disagreement preservation enforced — pytest constructs perspective list with opposing conclusions, asserts `Synthesis.explicit_disagreements != []` AND `final_recommendation == INVESTIGATE`
- [ ] Cost tracker enforced — pytest dispatches use case with $1 budget cap, asserts `CostBudgetExceeded` raised AND thesis NOT persisted
- [ ] No framework imports in `packages/domain/analysis/**` — grep `from fastapi\|from pydantic\|import django` returns 0
- [ ] Cross-BC import grep — `grep -r "from packages.domain.market_data\|from packages.domain.fundamental\|from packages.domain.news" packages/domain/analysis/` returns 0 (cross-BC types come from `packages.contracts.types` only)
- [ ] mypy --strict + ruff: 0 errors on Phase 2 surface; D1 baseline still 0
- [ ] LLM-math creep grep in `packages/{domain,application,infrastructure}/analysis/`: `r"approximately\|around\|roughly\|~ \d+%"` returns 0 hits in production code

### Decision tier

**IMPL** per D-014 chosen Option A. Sub-decisions IMPL-tier:
- StrEnum vs Enum (StrEnum per S27 + S36 precedent)
- Frozen vs mutable aggregate (frozen — re-issue Thesis on state transition; matches S27 Position pattern)
- Asyncio.gather vs TaskGroup (asyncio.gather per spec 001 verbatim; TaskGroup Python 3.11+ optional)

If S42 surfaces ARCH-tier question (e.g., "should we wire EventBus to Redis Streams now?") → escalate via Q&A bundle, do NOT silently decide.

### Carry-overs from S41

- D-014 § Open Questions: Q-S41-1 (Quant model) + Q-S41-2 (personal-risk-profile fill) — proceed Recommended defaults if user has not responded by S42 entry; IMPL-S42-N deviation documented if so
- spec 006 § A.9 glossary check: 5 NEW UL terms (PerspectiveAnalysis / Synthesis / GroundedPoint / TradeOffMatrix / Recommendation+ConfidenceLevel) — S42 entry runs `/drill-me` incremental for these terms before first entity ships (≤5-min cost; per L-S30-1 VBW)
- L-S30-1 VBW pre-flight doctrine APPLIED at every NEW Write; Phase 1 + S31/S33/S34/S36 all confirmed effective

### Risks (S42-specific)

- **R1 (MED) — 16-file MULTI budget overrun >230K**: pre-flight projection at S42 entry mandatory; split S42a (domain + ports + use case + thesis_recorded event) / S42b (adapters + synthesizer + data-gatherer + repository + cost-tracker + tests) if exceeds threshold. Mirror Phase 1 plan R1 doctrine.
- **R2 (HIGH) — LLM perspective system_prompt may need tuning post-S43a dogfood**: spec 006 § B.5 prompts are first-pass; if S43a 5-thesis dogfood reveals LLM-math creep or weak bear cases, prompt iteration deferred to Phase 3 entry NOT S42 (master-plan §S42 binding).
- **R3 (MED) — ThesisRepository SQLite schema may need migration support**: Phase 3 Postgres swap; document migration path in code comment + D-014 § Risks. `payload_json` portable across substrate.
- **R4 (MED) — personal-risk-profile.md unfilled cascades to Quant agent context**: charter-floor defaults wire-in; document IMPL-S42-N if user has not filled; surface to S43a as "thesis quality reduced" caveat.
- **R5 (LOW) — Cross-BC import discipline at infra layer**: `Phase1DataGatherer` reads BC-1 + BC-2 + BC-5 repositories — that's by design (orchestrator is application layer; gatherer is infra under application). All cross-BC types come via `packages/contracts/types/`. Verify at S42 close: grep cross-BC imports inside `packages/domain/analysis/` = 0.

### Open questions (queued-grill candidates)

| ID | Question | fire_when |
|---|---|---|
| Q-S42-1 | Async EventBus (in-process Phase 2) vs Redis Streams now? | S42 mid-session — recommend in-process per Phase 2 doctrine; defer Redis Phase 4+ |
| Q-S42-2 | Streamlit version pin: ≥1.32 or latest? | S42 entry — context7 fetch latest stable; pin in pyproject.toml |
| Q-S42-3 | Reproducibility AC-5: should `data_snapshot_md5` include news-article ordering or just claim_ids? | S42 mid-session — recommend deterministic ordering by `(article_id, claim_id)` lexicographic |

---

## S43a — Track F UI + 5-Thesis Dogfood

### Meta

| Field | Value |
|---|---|
| Session type | FOCUSED_IMPL |
| Agent | main |
| Budget envelope | ~120-140K (per master-plan §S43a; FOCUSED_IMPL under 150K cap) |
| Predecessor | S42 |
| Successor | S43 (sandwich-verifier whole-Phase-2) |
| Decision tier | IMPL + 5 SCOPE artifact thesis (`real_thesis: true`) |

### Goal

Ship Streamlit page + CLI alternative + run 5 REAL thesis on VN30 stocks; satisfy Charter Month-3 SC-3 (5 thesis recorded) + SC-4 (`/thesis-validate` <5min). 5 thesis files at `agent-workspace/memory/thesis-log/` with `real_thesis: true` frontmatter; bear case ≥3 distinct points each; every number traceable to SQL `-- query: ...` audit comment per VHM exemplar pattern.

### Pre-flight reads (≤5 files)

1. `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md` § B.7 (Streamlit UI design)
2. `agent-workspace/memory/thesis-log/_template.md` + `agent-workspace/memory/thesis-log/2026-04-30-VHM-exemplar.md` (existing format + 15-SQL-query Q1-Q15 pattern Track F UI must mirror)
3. `agent-workspace/memory/personal-risk-profile.md` (verify USER FILL state at S43a entry — if filled, fold into Quant agent context; else charter-floor)
4. context7 fetch Streamlit current-version docs (page navigation + caching)
5. S42 close checkpoint — verify BC-8 + use case wired

### Deliverables (~10 files; ~700 LOC; ≥10 tests)

1. NEW `apps/dashboard/__init__.py` ≤10 LOC
2. NEW `apps/dashboard/main.py` ≤60 LOC (Streamlit entry; sidebar nav)
3. NEW `apps/dashboard/pages/validate_thesis.py` ≤180 LOC (per spec 006 § B.7 verbatim adapt)
4. NEW `apps/dashboard/components/thesis_card.py` ≤120 LOC (renders thesis card per spec 001 § A.4 markdown schema; UTF-8 Vietnamese-aware)
5. NEW `apps/cli/validate_thesis.py` ≤100 LOC (Click CLI; same use case wired; writes thesis to `agent-workspace/memory/thesis-log/{as_of}-{ticker}.md`)
6. NEW `agent-workspace/memory/thesis-log/2026-MM-DD-{ticker}.md` × 5 files — REAL thesis (`real_thesis: true`); 5 different VN30 tickers chosen per user picks at S43a entry (recommend AskUserQuestion 1Q SCOPE-tier "Pick 5 VN30 stocks" with default = first 5 alphabetical excluding VHM); each follows `_template.md` format with `-- query: SQL` audit comments per VHM exemplar Q1-Q15 pattern
7. NEW `apps/dashboard/test_smoke.py` ≤100 LOC (≥3 tests via Streamlit testapi)
8. NEW `apps/cli/test_validate_thesis.py` ≤80 LOC (≥7 tests via Click CliRunner — happy path + bear-case-fail + cost-cap + reproducibility + 5-ticker matrix)
9. EDIT `pyproject.toml` (+streamlit ≥1.32 dep)
10. EDIT `agent-workspace/memory/current-execution.md` § Active Focus Track + Track status (S43a row)

### Success Criteria (6 per master-plan §S43a)

- [ ] Streamlit page renders thesis card per spec 001 § A.4 schema; Vietnamese diacritics correct
- [ ] CLI exits 0 for all 5 tickers; each thesis ≤5 minutes wall-clock; each thesis ≤$3 cost (CostTracker enforced)
- [ ] 5 thesis files have `real_thesis: true` + bear case ≥3 distinct points + ≥3 distinct categories + every number traceable to SQL `-- query: ...` audit comment
- [ ] Reproducibility: re-run 1 of 5 with same `(ticker, as_of)` → identical `thesis_id` + identical content per AC-5
- [ ] D1 baseline still 0; mypy --strict + ruff clean
- [ ] LLM-math creep grep in 5 NEW thesis-log files: 0 hits (`r"approximately\|around\|roughly\|~ \d+%"`)
- [ ] VF-5 acceptance: ≥1 of 5 thesis exhibits explicit disagreement panel populated (otherwise prompt drift detected; iterate at Phase 3 entry NOT S43a)

### Decision tier

**IMPL** per D-014 chosen Option A. SCOPE-tier sub-decision: 5-ticker pick (AskUserQuestion 1Q at S43a entry; default = first 5 VN30 alphabetical excl VHM = [BID, BVH, CTG, FPT, GAS] — pick is SCOPE because affects user-facing dogfood quality).

### Carry-overs from S42

- BC-8 aggregate + use case + adapters + repository all wired
- D-014 § Open Questions: if user picked Sonnet for Quant at S42, S43a thesis cost re-estimate $1.30 → $0.80 avg
- personal-risk-profile.md state re-checked at S43a entry; if filled mid-S42, Quant agent context upgrades

### Risks (S43a-specific)

- **R1 (HIGH) — Cost overrun on 5-thesis dogfood**: 5 × $3 = $15 ceiling; session hard-cap $20; if any thesis breaches $3, mark `cost_violation: true` in frontmatter and surface at S43; bear retry loop is the highest-likelihood breach vector.
- **R2 (MED) — Streamlit dependency installation Phase 2 first frontend touch**: pin version in pyproject.toml; verify clean install; fallback to CLI-only dogfood if Streamlit blocks
- **R3 (MED) — User AskUserQuestion (5-ticker pick) blocks if user picks <5 or defers**: fall back to default [BID, BVH, CTG, FPT, GAS]; document IMPL-S43a-N
- **R4 (MED) — VF-5 disagreement signal absent in all 5 dogfood thesis**: indicates prompt drift (Bear vs Bull too aligned); deferred to Phase 3 prompt iteration per master-plan §S42 R2 doctrine; document at S43a close as carryover for Phase 3 entry
- **R5 (LOW) — LLM hallucinated source_url in dogfood thesis**: post-LLM validator + GroundedPoint `__post_init__` catch; verifier S43 spot-checks 5%

### Open questions

| ID | Question | fire_when |
|---|---|---|
| Q-S43a-1 | 5-ticker pick — user explicit or default? | S43a entry — AskUserQuestion 1Q SCOPE-tier; default first 5 VN30 alphabetical excl VHM |
| Q-S43a-2 | Should each dogfood thesis include personal-bias check section per VHM exemplar template? | S43a entry — recommend YES (template default); user-owned ticker triggers HIGH bias flag; confirmation-bias risk |
| Q-S43a-3 | Charter Month-3 SC-3 5-thesis count: dogfood thesis count or only theses with horizon outcome? | S43a close — recommend dogfood count (5 entries with `real_thesis: true`); horizon-outcome calibration is Phase 4+ |

---

## Total Track F Envelope (S41 + S42 + S43a + S43)

| Session | Type | Budget | Cumulative |
|---|---|---|---|
| S41 (this PLAN) | PLAN | 50-80K main + ~150K subagent | ~200K combined |
| S42 | MULTI_TASK_IMPL | 200-240K | 450K |
| S42a/b (if split) | MULTI/MULTI | 130-160K + 110-140K | 470K (modest split overhead) |
| S43a | FOCUSED_IMPL | 120-140K | 580K |
| S43 (whole-Phase-2 verifier; not Track F-only) | VERIFY | 100-150K (subagent) | 730K |

Track F-only ~580K (S41+S42+S43a). S43 covers all of Phase 2.

---

## Files Created by This Sub-Plan (S41 deliverables)

1. `specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md` (~620 LOC vs ≤350 advisory — see § Deviations below)
2. `agent-workspace/memory/decisions/014-track-F-architecture.md` (~190 LOC vs ≤140 advisory — see § Deviations)
3. `agent-workspace/session-plans/pending/006-S41-track-F-impl-sub-plan.md` (this file)

---

## Connection to Charter + Master-Plan + Constitution

| Source | Section | How this sub-plan honors |
|---|---|---|
| `PROJECT_CHARTER.md` § Phase 1 (Month 3) | SC-3 (5 thesis) + SC-4 (<5min) | S43a 5-thesis dogfood satisfies SC-3; CLI + Streamlit both ≤5min satisfy SC-4 |
| Charter § Core Principles | P1-P10 | P1 evidence (every claim source_url) / P2 simplicity (3 perspectives, no speculative 6) / P3 adversarial (bear case ≥3 mandatory) / P9 NO LLM math (verifier S43 grep) / P10 deterministic risk (RiskRule unchanged from S27) |
| `agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md` § S41 + § S42 + § S43a | All 5 success criteria per § S41 | Spec 006 frontmatter ✅ / 3 system_prompts ≥40 LOC ✅ / cost profile ≤$2 avg ✅ / personal-risk-profile prereq surfaced ✅ / D-014 12 fields ✅ |
| `specs/tier2-feature/001-validate-investment-thesis.md` | All Phase 1 § A + § B | Phase 2 lifts spec 001 `Phase1*` symbols to production verbatim; spec 006 binds via `related_specs` frontmatter |
| `agent-workspace/constitution/invariants.md` | I-1, I-S1, I-S5, I-S7, I-S10, I-S11, I-S12, I-S35, I-40 | All enforced at aggregate boundary or use case boundary or output framing |
| `agent-workspace/CLAUDE.md` Contract Rules | 1-7 | Constitution immutable preserved; cross-BC via contracts/ only; agents never commit |

---

## End of Sub-Plan

> Next action: User runs `/session-start` (or types "continue" if autonomous) → S42 entry; pre-flight reads §S42 above; pre-flight projection check (split if >230K); MULTI_TASK_IMPL execute per § Deliverables.
