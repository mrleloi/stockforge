# Project Memory — StockForge

> Updated: 2026-04-30 (S30 — Phase 1 closure SHIPPED; D-011 ACCEPTED Phase 2 entry SCOPE-tier user-gated Option A; 4 NEW deliverables [thesis-log/_template.md + VHM exemplar + post-mortems/_template.md + D-011]; R1 partial fix shipped 1 of 8 obs mypy errors cleared; 3 IMPL-S30-* deviations documented; 1 NEW lesson candidate L-S30-1).
> Update cadence: After phase boundaries, after significant decisions, weekly at minimum.

## Current Phase

**Phase 2** — Foundation Tier 1+2 (Tier 1+2 VN30 rollout; entered 2026-04-30 via D-011 SCOPE-tier user-gated Option A; per Charter Month 6 success criteria + spec-T1-001 § B.2). Phase 1 = COMPLETE 2026-04-30 (S25-S30 all DONE).

Goals (REV-3 after UP-06 + UP-08; sequencing post-Track-7-split):
- Tracks 0-5 (DONE through S8): pattern-mining + workspace dualism + provenance + intent classifier + Q&A escalation + loop-resilience hooks
- Track 5.5a (DONE S4): Layer manifest + /attach skill (no multi-tenant; tag-only)
- Track 5.5b (DONE S5+S6+S7): Sync infrastructure (intent-vs-impl-diff agent + sync-state + grilling hook + correction-rate-tracker)
- **Track 5.5c (DONE S8+S13)**: Self-cap full set — decompose-work + capability-map + promote-rule (S8) + try-n-approaches + failure_mode wire-in + metric-function + JSONL/OTEL design + L-1 re-dispatch (S13)
- Track 5.5d (DONE S10+S11+S12): Self-learning ETL pipeline (boundary + sweeper + index + Karpathy + DSPy dogfood SHIPPED)
- **Track 6 REWRITE primary (DONE S14)**: progressive-disclosure refactor of top-8 D1 violators; 16 D1 carry-over to Track 6 secondary (post-Phase-0 cleanup or absorbed S19)
- **Track 7 PLAN (DONE S15)**: constitution port plan composition; 9 queued-grill items closed via 3 AskUserQuestion batches
- **Track 7 IMPL (DONE S16)**: D-003 REV-4 + D-005 REV-1 amendments; bash-hook-lint.sh + 3 hook wire-ins; 6 proposals at agent-workspace/proposals/; 4 skill/memory amendments via references/ companion + direct edits; promotion-routing-S16.md
- **Track 8a (DONE S17)**: Confidence Score System SHIPPED via D-006 + sync-tracker layer (events.tsv / state.tsv / weights.yaml / _index.md / README.md) + sync-tracker-update.sh + sync-tracker-render.sh + sync-pull skill; bash+TSV substrate per IMPL-S17-1 (L-S11-1 portability binding); SQLite migration deferred Phase 1+
- Track 8b (S18 NEXT): Memory L0/L1 extraction (cleanText + TranscriptCache; ports claude-sessions to packages/observability/)
- Track 9 (S19 or S20): Self-Awareness + OTEL (REDUCED ~50K — Phase 0 design-only artifact lives at `self-awareness/otel-design.md`)
- Track 6 secondary (S19 or post-Phase-0): 16 D1 violators closure
- Final verifier S20

20 sessions estimated (REV-3 + Track 7 PLAN+IMPL split). Expected total: ~2.44M tokens (user-accepted via D-005 Q5=A 2026-04-29).
Plan file: `agent-workspace/session-plans/pending/001-port-from-orch.md` (filename retained; content = 14-track REV-3 plan).

---

## Phase Goals Tracker

| Phase | Target | Status | Started | Completed |
|---|---|---|---|---|
| 0 — Harness Bootstrap (NEW) | Workspace dualism, provenance, Confidence Score, Self-Awareness, port from orch | DONE | 2026-04-29 | 2026-04-30 (S22) |
| 1 — Foundation (was Project Setup) | Day 1 checklist + customize constitution + UL glossary 42 VN terms + monorepo 9 BCs + first entities BC-1+BC-9 + Tier 1 ingestion adapter (vnstock+TCBS+SQLite) + 248 VHM bars + thesis-template + VHM exemplar + post-mortems-template | DONE | 2026-04-30 (S23) | 2026-04-30 (S30) |
| 2 — Foundation Tier 1+2 (was Phase 1) | Tier 1+2 VN30 rollout (~30 tickers); BC-2 Fundamental + BC-5 News (CafeF + NDH + VietnamBiz); R2 TCBS-endpoint or DNSE/KBS pivot; thesis pipeline expansion 3-perspective; 9 proposals user-approve batch parallel | IN PROGRESS | 2026-04-30 (S31 PLAN next) | - |
| 3 — Edge Sources Tier 3+4 (was Phase 2) | KOL tracking + crowd sentiment | NOT STARTED | - | - |
| 4 — Multi-perspective (was Phase 3) | Adversarial agents, thesis system | NOT STARTED | - | - |
| 5 — Compounding (was Phase 4) | Karpathy outer loop, calibration drives weights | NOT STARTED | - | - |

---

## Recent Architectural Decisions (last 5)

> Newest first. Keep only last 5. Full ADRs in `agent-workspace/memory/decisions/`.

### 2026-04-30 — D-011 — Phase 2 entry: Tier 1+2 VN30 rollout (SCOPE-tier user-gated)
**Source**: master-plan 004 § S30 + S30 AskUserQuestion 1Q + Charter § Month 6 success criteria + spec-T1-001 § B.2 + S29 verifier verdict PASS-WITH-RESIDUE.
**Picks**: Option A (Recommended) — Enter Phase 2 — chosen over B (Pause for dogfood week; user judged Phase 2 momentum more valuable) and C (User-approve 9 proposals first; runs in parallel, not a gate per D-011 § Option C analysis).
**Impact**: Phase 1 = COMPLETE 2026-04-30 (S25-S30 all DONE). Phase 2 entry approved SCOPE-tier; binding_phase: 2; Phase 2 PLAN next session (S31). Phase 2 expected scope: VN30 universe (~30 tickers) + BC-2 Fundamental + BC-5 News (CafeF/NDH/VietnamBiz) + R2 TCBS closure or pivot; ~600-900K envelope (similar to Phase 1).
**Status**: ACCEPTED via SCOPE-tier user-gate; Q-B2 doctrine satisfied (charter/SCOPE-tier explicit letter pick).

### 2026-04-30 — D-010 — VN-domain constitution amendment proposals (Rules 12-15 + I-S55-I-S65 + personal-risk-profile template)
**Source**: master-plan 004 § S26 + glossary v1.0 (S25; 42 VN terms) + spec 000 § B + Charter § First Sub-Scope + Day 1 § A.4 + § B.5.
**Picks**: Option B (separate proposal files for VN-domain Rules 12-15 vs S16 Hook Portability Rule 11) chosen over A (fold; conflates orthogonal concerns) and C (defer Phase 2; drifts master-plan).
**Impact**: 3 deliverables — financial-data-protocol-amendment-VN.md (116 LOC; Rules 12-15: T+2.5 / Room ngoại / Sàn-tier / FX VND-USD) + invariants-amendment-VN.md (108 LOC; I-S55-I-S65 = 11 NEW VN-specific invariants) + personal-risk-profile.md (110 LOC; 33 USER FILL placeholders across 7 sections per Day 1 § B.5). 9 proposals net post-S26 (master-plan said 8 via fold; documented as drift item).
**Status**: ACCEPTED-as-PROPOSAL via IMPL-tier (autonomous_mode=true). PENDING user explicit-approve to move proposals → constitution/. S27-S29 reference existing constitution Rules 1-10 + I-S1-I-S54 only.

### 2026-04-30 — D-009 — VHM as Phase 1 thin-slice exemplar
**Source**: PROJECT_CHARTER.md § First Sub-Scope + master-plan 004 § Thin-Slice Definition + S25 Q-S25-1 SCOPE-tier user-gate.
**Picks**: A (VHM Recommended) chosen over B (VIC; conglomerate complexity) and C (VPB; needs banking BC-2 maturity). User explicit-pick via AskUserQuestion 1Q.
**Impact**: locks S25-S30 thin-slice scope to VHM exemplar; ~250 daily Bars at S28; 1 exemplar thesis at S30; spec 000 frontmatter exemplar_stock=VHM.
**Status**: ACCEPTED via SCOPE-tier user-gate.

### 2026-04-29 — D-006 — Track 8a Confidence Score System (bash+TSV substrate per IMPL-S17-1)
**Source**: D-002 § Track 8 + REV-2 § A + Q&A A4/A5/A6 + L-S11-1 + Charter Principle 8.
**Picks**: IMPL-tier self-decide; Option B (bash+TSV) over SQLite+python and defer.
**Impact**: 5 categories scoring + asymmetric weights + 4 thresholds + reversal protocol + must_grill counter; sync-tracker layer + 2 hooks + sync-pull skill. Phase 1+ migration to SQLite when Track 8b lands python+sqlite3.
**Status**: ACCEPTED via IMPL-tier; SHIPPED S17 with smoke test PASS.

### 2026-04-29 — S16 — Track 7 IMPL — Constitution Port Ratification (D-003 REV-4 + D-005 REV-1)
**Source**: S15 PLAN file 003-... § 2 + § 4 + 9 closed queued-grill items + 10 L-S* lessons.
**Deliverables**: D-003+D-005 amendments; bash-hook-lint.sh + 3 hook wire-ins; 6 proposals + 1 pre-existing = 7 batch; try-n-approaches/SKILL.md +21; write-a-skill/references/best-practices.md NEW; harness_bootstrap_permission_override.md +L-S14-3.
**Status**: SHIPPED. 9 proposals pending user explicit approve post-S26.

---

## Active TODOs (top 10)

> Phase 0 closed permanently at S22. Phase 1 thin-slice sequenced S25→S30 in `agent-workspace/session-plans/pending/004-S24-phase-1-thin-slice-plan.md`.

### Phase 0 — Harness Bootstrap (DONE)
- [x] **All 14 tracks** — closed S22; sandwich-verifier S21 verdict PASS-WITH-RESIDUE; 3 non-blocking residue fixed S22

### Phase 1 — Foundation (active — VHM thin-slice S25→S30)
- [x] **S23** — Phase 1 entry: sync-bundle 4 confirmations + monorepo skeleton 9 BCs SHIPPED at `packages/domain/`
- [x] **S24** — Phase 1 second sub-track: Q-D1 + Q-D2 queued-grill closures; master-plan 004 SHIPPED at session-plans/pending/ (S25→S30 thin-slice on VHM exemplar)
- [x] **S25** — Phase 1 third sub-track: UL glossary v1.0 (42 VN terms; 8 critical) + thin-slice spec frame at `specs/tier2-feature/000-phase-1-thin-slice-VHM.md` (188 LOC dual-layer) + D-009 ACCEPTED via Q-S25-1 (VHM Recommended) + drill-me transcript
- [x] **S26** — Phase 1 fourth sub-track: VN-domain constitution proposals (3 files + D-010); 9 proposals net post-S26
- [x] **S27** — MULTI_TASK_IMPL first entities BC-1+BC-9: 23 files / 1,532 LOC production / 79 tests PASS; cross-BC contract event `position_value_computed`; 3 IMPL-S27-* decisions; L-S27-1 candidate
- [x] **S28** — FOCUSED_IMPL Tier 1 ingestion adapter: 13 files / 1,223 LOC / 21 fixture tests PASS; live smoke 248 VHM bars on disk; mypy --strict + ruff clean on 44 Phase 1 files; 3 IMPL-S28-* decisions; L-S28-1 candidate (vendor-API drift)
- [x] **S29** — VERIFY sandwich-verifier (fresh context; agent ID ad3fbd0e52b1b29a2; ~98K reported tokens within L-S21-1 envelope): all 10 V dimensions GREEN + 9 A1-A9 probes GREEN on Phase 1 surface 44 files; verdict PASS-WITH-RESIDUE; phase_gate UNBLOCKED; 4 LOW residue items (R1 obs mypy / R2 TCBS 404 / R3 LOC ceilings / R4 LOC bookkeeping)
- [x] **S30** — FOCUSED_IMPL Phase 1 closure: R1 partial fix (1 of 8 obs mypy cleared via StrEnum tail at test_state_machine.py:30) + eval-sets ratified-in-place IMPL-S30-1 + thesis-log/_template.md NEW (141 LOC) + VHM exemplar thesis NEW (145 LOC; 15 deterministic SQL queries Q1-Q15 audit-trail; PASS recommendation; bear case 4 distinct points) + post-mortems/_template.md NEW (123 LOC; +2.5% IMPL-S30-2) + D-011 ACCEPTED Phase 2 entry SCOPE-tier user-gated Option A + Phase 1 close ceremony

### Phase 2 — Foundation Tier 1+2 (entered 2026-04-30; PLAN next)
- [ ] **S31 NEXT (PLAN)** — Phase 2 master-plan author: Track A R2 TCBS endpoint discovery or DNSE/KBS pivot / Track B VN30 universe expansion BC-1 ~30 tickers / Track C BC-2 Fundamental ingestion / Track D BC-5 News stub + first scraper (CafeF first; rate-limited per I-S34) / Track E 9 proposals user-approve batch (parallel; not a gate) / Track F thesis pipeline 3-perspective expansion per spec 001 § B.2

---

## Known Issues

(None yet)

---

## Current Invariants (reference)

See `agent-workspace/constitution/invariants.md` for full list.

Highest-priority stock-specific:
- **I-S1**: NO LLM math — every number from code
- **I-S2**: Point-in-time integrity for backtest
- **I-S3**: Survivorship-aware universe construction
- **I-S10**: Thesis must include bear case
- **I-S20**: KOL recommendations tracked to outcome
- **I-S35**: All output framed as research aid, not advice

---

## Key References

- **Charter**: `PROJECT_CHARTER.md`
- **Manual**: `AGENT_OPERATING_MANUAL.md`
- **Spec template**: `SPEC_TEMPLATE.md`
- **Strategic spec**: `specs/tier1-strategic/001-four-tier-signal-architecture.md`
- **Feature specs**: `specs/tier2-feature/001-005-*.md`
- **Routing**: `agent-workspace/memory/current-execution.md`
- **Learned rules**: `agent-workspace/memory/agent-notes.md`
- **Thesis log**: `agent-workspace/memory/thesis-log/`
- **Calibration data**: `agent-workspace/calibration/`

---

## Environment Info

(Fill in after setup)

- **OS**: 
- **Python version**: 
- **Claude Code version**: 
- **Local infra**: docker-compose with Postgres 16 + TimescaleDB + Redis
- **Obsidian**: installed/not installed

---

## Notes for Agent

- When starting a new session, read this file first
- Update this file when: phase changes, architectural decisions made, known issues surface
- Don't embed state that goes stale — link to session logs and current-execution.md instead
- Keep under 2K tokens total — reference other files for detail
- For stock-specific calibration data, link to `agent-workspace/calibration/` files, don't dump here
