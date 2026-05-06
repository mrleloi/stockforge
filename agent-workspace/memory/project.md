# Project Memory — StockForge

> Updated: 2026-05-05 (S48d — Phase 2.5 HH-C ritual codification 4/4 DONE: 3 NEW Stop-hook watchdogs + CLAUDE.md § Session End extension 5→9 steps via D-028 + drift-signals.md Tiered Coverage Map via D-029 + 2 sync-state closures sync-027 + sync-036).
> Update cadence: After phase boundaries, after significant decisions, weekly at minimum.

## Current Phase

**Phase 2.5** — Harness Hardening (NEW; entered 2026-05-05 S48 post-audit; runs S48b-S48i; 8 substantive tracks HH-A..HH-H; ~750K-1.1M envelope). Pre-condition for Phase 3 Track I resume.

**Phase 3 — Tier 3+4 KOL + pump + outer-loop**: PAUSED at S47 (Track G+H DONE; Track I S49 awaits Phase 2.5 close per pre-condition checklist).

Goals (Phase 2.5 — derived from 2026-05-05 audit + root cause 3-axes):
- HH-A Foundation repair (S48b NEXT): wire 2 charter-prescribed orphan hooks (vendor-api-probe ✓ DONE this turn + tier1-bloat-check ✓ DONE this turn); refresh project.md (this Edit); manifest regen V1 invariant; HH-A.7 NEW = current-execution.md Tier 1 bloat (34K tok→≤8K target)
- HH-B Telemetry repair (S48c): fix dispatch.jsonl JOIN; populate failure_mode + tokens_used; audit DR1-DR12 (8/12 dead); reactivate sync-tracker
- HH-C Continuous-loop ritual (S48d): 4 NEW Stop-hook watchdogs codifying continuous obligations
- HH-D Self-pause Mode-E charter promotion (S48e): tier-3 escalation after 4 hook-tier recurrences
- HH-E Q&A escalation upgrade (S48f): URGENT-tier surface + lifecycle contract revision
- HH-F Self-knowledge bootstrap (S48g): ETL D-001..D-027 + 17 M-* → ≥30 profile cards / category
- HH-G Portability validation (S48h): general-harness CLAUDE.md template + /attach smoke test
- HH-H Auto-/clear-handoff safety (S48i): fix incident root — checkpoint write MUST precede any /clear+continue

Re-enable autonomous_mode CHỈ sau 8-item pre-condition checklist passes (per 009 § "Re-enable autonomous_mode gate") + user explicit ratification.

Plan file: `agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md`. Companion: `observations/2026-05-05-harness-alignment-audit.md` + `observations/2026-05-05-root-cause-3-axes.md`.

---

## Phase Goals Tracker

| Phase | Target | Status | Started | Completed |
|---|---|---|---|---|
| 0 — Harness Bootstrap | Workspace dualism, provenance, Confidence Score, Self-Awareness, port from orch | DONE | 2026-04-29 | 2026-04-30 (S22) |
| 1 — Foundation VHM Thin-Slice | Day 1 + UL glossary 42 VN terms + monorepo 9 BCs + first entities BC-1+BC-9 + Tier 1 ingestion + 248 VHM bars + thesis template + VHM exemplar | DONE | 2026-04-30 (S23) | 2026-04-30 (S30) |
| 2 — Foundation Tier 1+2 | VN30 rollout ~30 tickers; BC-2 Fundamental + BC-5 News; R2 closure via SSI direct httpx; Track F thesis pipeline 3-perspective; 9 charter promote bundles | DONE | 2026-04-30 (S31) | 2026-05-04 (S43e/S43f) |
| 2.5 — Harness Hardening (NEW) | 8 tracks HH-A..HH-H: foundation / telemetry / ritual / Mode-E charter / Q&A escalation / self-knowledge bootstrap / portability / auto-reboot safety | IN PROGRESS | 2026-05-05 (S48) | - |
| 3 — Tier 3+4 KOL + pump + outer-loop | BC-6 Influence Network (S45+S46+S47 DONE; S49 Track I PAUSED) + BC-7 sentiment/pump + BC-9 outer-loop | PAUSED | 2026-05-05 (S44) | - |
| 4 — Multi-perspective | Adversarial agents, thesis system maturation | NOT STARTED | - | - |
| 5 — Compounding | Karpathy outer loop, calibration drives weights | NOT STARTED | - | - |

---

## Recent Architectural Decisions (last 5)

> Newest first. Keep only last 5. Full ADRs in `agent-workspace/memory/decisions/`.

### 2026-05-05 — D-029 — S48d charter-promote drift-signals reconciliation (Tiered Coverage Map; DR1-DR12 ↔ D1-D9)
**Source**: S48c HH-B.4 audit observation + Q-S48c-1 carry-forward + S48d 4-Q AskUserQuestion bundle Q2=ACCEPT.
**Picks**: Part A doctrine reorganization via deny-lift cycle; Part B hook ext (DR1/3/6/8 detectors) already shipped S48c.
**Impact**: drift-signals.md +40 LOC "Tiered Coverage Map" subsection (Tier-A/B/C); D9 zero-residue verified (only drift-signals.md md5 changed). Internal label rename D1→DR-A1 etc deferred to next routine hook patch.
**Status**: ACCEPTED via CHARTER-tier deny-lift.

### 2026-05-05 — D-028 — S48d HH-C.4 CLAUDE.md § Session End ritual extension (5 → 9 steps)
**Source**: Phase 2.5 HH-C ritual codification + DRC-1 audit + S48d 4-Q AskUserQuestion bundle Q1=ACCEPT.
**Picks**: 4 NEW steps (#6 mistake-log update / #7 staleness verify / #8 auto profile-template / #9 auto promote-rule). Companion hooks HH-C.1/2/3 shipped same session (3 NEW Stop hooks ~355 LOC total; smoke 6/6 GREEN).
**Impact**: CLAUDE.md +50 tok in always-loaded Tier 1 (~0.6% ceiling delta). Codifies decision-discipline.md Rule 4b (D-026) lesson-synthesis discipline at the agent-side ritual layer. Hooks enforce mechanically.
**Status**: ACCEPTED via CHARTER-tier (CLAUDE.md USER-GATE convention).

### 2026-05-05 — D-027 — BC-6 Influence Network architecture (Tracks G+H+I; SQLite extension; KOLChannelAdapter Protocol; Recommendation domain aggregate)
**Source**: spec 002 KOL + spec 003 pump + Phase 3 master-plan 007 § R-P3-1 + S45 sandwich-architect dispatch.
**Picks**: SQLite extension over fresh DB; Protocol over inheritance for KOLChannelAdapter; domain Recommendation aggregate over ValueObject.
**Impact**: 152 LOC. S46 Track G + S47 Track H IMPL DONE; S49 Track I PAUSED awaiting Phase 2.5 close.
**Status**: ACCEPTED via ARCH-tier (sandwich-architect S45).

### 2026-05-05 — D-026 — S43e Charter promote bundle C1+C2 (architecture LLM Substrate Boundary + decision-discipline Rule 4b)
**Source**: S43e harness-recovery + S43f 4-Q AskUserQuestion bundle; deny-lift mechanism (S38 precedent).
**Picks**: C1 ACCEPT + C2 ACCEPT — bundled deny-lift cycle ratified both charter amendments.
**Impact**: architecture.md +25 LOC LLM Substrate Boundary subsection (BP-S43b-1/2/3 cited verbatim) + decision-discipline.md +33 LOC Rule 4b mandatory lesson-synthesis at session-end. Watchdog flipped advisory → strict.
**Status**: ACCEPTED via CHARTER-tier deny-lift.

### 2026-05-04 — D-025 — Phase 2 envelope amendment +50-65% (~860K-1.25M → ~1.60M-1.85M main + ~700K subagent)
**Source**: S43d master-plan calibration vs Phase 2 actual; Q&A 003 Q10=A.
**Impact**: 4 structural drivers attributed (META_LOOP S35 + sandwich-architect S41 + harness-recovery S43b + rule-application S43c+S43d). Phase 3 master-plan bakes 4 standing-overhead reserves.
**Status**: ACCEPTED via IMPL-tier amendment.

### 2026-05-04 — D-024 — HR-4 memory-routing-tree CHARTER promotion
**Source**: S43c bundle 2 + L-S43b-5 (12+ user-memory entries should-be agent-notes).
**Impact**: memory-routing-tree.md moved to constitution/; companion `memory-routing-audit.sh` Stop hook wired; 12-field routing schema codified.
**Status**: ACCEPTED via CHARTER-tier deny-lift.

### 2026-05-04 — D-018..D-023 — S43c Bundle 2 charter promote (7 amendments batch) — moved to archive
(See `agent-workspace/memory/decisions/018-S43c-...md` through `023-S43c-...md` for full ADR text. Stub kept for context cross-ref.)

### Pre-S48 history (archived, last 5 stale)

D-011/010/009/006/S16 — see `agent-workspace/memory/decisions/` for full ADR text.

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
