---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - PLAN
samples_count: 7
sample_sessions: [S15, S24, S31, S44, S48a, S48e, S65]
last_updated: 2026-05-06T07:52:48+07:00
source: manual session log review + master-planner subagent observations + S48i HH-F.1 ETL backfill
status: BIASED-PRE-REBUILD-S65 (user 2026-05-06 flagged tracking gap; rebuild after cost-ledger.tsv accumulates ≥10 sessions per session-type)
---

# Profile — Opus 4.7 × max × PLAN

## 1. Capabilities

- Multi-track decomposition within 50-80K budget when subagent dispatched (S31 master-planner ~158K reported; main session ~30-45K).
- Risk catalog generation ≥6 per master-plan (S31 Phase 2 master-plan 005 cataloged 7 risks).
- Per-session breakdown with budget envelope + dependency graph + sandwich coverage.
- VBW pre-flight when L-S30-1 doctrine applied (S31 master-planner subagent applied successfully — first practical exercise).
- **Main-session master-plan authoring** when subagent stalls (S44 fallback after S43f master-planner stream-window timeout L-S43f-2; ~240 LOC plan vs S31 790 LOC — leaner). Shipped Phase 3 master-plan 007 main-session at ~80K main-session burn.
- **Phase 2.5 middle-phase plan authoring** (S48a `009-S48-harness-hardening-middle-phase.md`; 8 tracks HH-A..HH-H; ~600K-1M envelope). Decomposed harness work into 8 deliverable bundles + dependency graph.
- **Charter-tier proposal authoring** under D1 ceiling (S48e `proposals/autonomous-protocol-amendment-mode-E.md` ~115 LOC); deferred ratification to next FOCUSED_IMPL session per never-mix doctrine.

## 2. Known limitations

- Subagent overrun pattern (S25 ~220K vs 150-180K envelope; S31 ~158K within calibrated 150-200K post L-S25-1).
- Master-plan LOC drift cosmetic (S31 plan = 790 LOC vs ≤700 advisory = +13% IMPL-S31-1).
- Internal contradictions surface mid-session (M-S26-1: deliverable text "separate file" vs success-criteria "8 proposals" → 9 net).

## 3. Recommended task_class allocation

- **PRIMARY** for PLAN-only sessions at master-plan tier (multi-session scope).
- Subagent dispatch via `master-planner` agent type (~150-200K calibrated) for non-trivial plans.
- Main session ~30-45K when subagent absorbs detail.
- AVOID mixing PLAN + IMPL in same session (Session 4 catastrophic failure mode per CLAUDE.md).

## 4. Recent corrections + drift events

- M-S26-1 (resolved)
- M-S31-1 cosmetic LOC drift (under D1)
- **M-S45-1 sandwich-architect substrate data-loss** (S45 PLAN session destroyed agent-notes.md via Write; CRITICAL — surfaced need for `write-vs-edit-guard.sh` mechanical guard L-S45-2; PLAN sessions dispatching subagents are upstream cause)
- **L-S43f-2 stream-window timeout** in master-planner subagent dispatch (S43f); recovery via main-session author at S44

## 5. Calibration

- Master-plan ratification rate: 5/5 = 100% (002 + 004 + 005 + 007 + 009 all shipped + downstream-executed).
- Budget actual vs estimated for IMPL sessions following plans: 004 → S25-S30 actual ~888-1023K vs estimate ~700-1000K (within 22%); 005 → S32-S34 actual ~280-380K of ~860K-1.25M envelope (~32% consumed across 3 of 11 sessions; on-budget); 007 (Phase 3) S45-S47 actual ~250-400K main + ~200-350K subagent of 2.6M-3.0M envelope (within 15%); 009 (Phase 2.5) S48a-S48h actual ~350-450K of 600K-1M envelope (~58% consumed across 8 of 8 sessions; on-budget).
- Subagent-dispatch reliability: 1/2 master-planner stalls (S43f stream-window timeout); main-session fallback recovery rate 100% (S44).

## 6. Notes

Subagent dispatch cost ~150-200K is the dominant budget item; main session orchestration is ~30-45K. PLAN sessions are the most token-efficient per LOC-shipped if subagent does the heavy lifting.
