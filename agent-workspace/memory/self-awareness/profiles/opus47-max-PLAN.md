---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - PLAN
samples_count: 3
sample_sessions: [S15, S24, S31]
last_updated: 2026-05-01T00:00:00Z
source: manual session log review + master-planner subagent observations
---

# Profile — Opus 4.7 × max × PLAN

## 1. Capabilities

- Multi-track decomposition within 50-80K budget when subagent dispatched (S31 master-planner ~158K reported; main session ~30-45K).
- Risk catalog generation ≥6 per master-plan (S31 Phase 2 master-plan 005 cataloged 7 risks).
- Per-session breakdown with budget envelope + dependency graph + sandwich coverage.
- VBW pre-flight when L-S30-1 doctrine applied (S31 master-planner subagent applied successfully — first practical exercise).

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

## 5. Calibration

- Master-plan ratification rate: 3/3 = 100% (002 + 004 + 005 all shipped + downstream-executed).
- Budget actual vs estimated for IMPL sessions following plans: 004 → S25-S30 actual ~888-1023K vs estimate ~700-1000K (within 22%); 005 → S32-S34 actual ~280-380K of ~860K-1.25M envelope (~32% consumed across 3 of 11 sessions; on-budget).

## 6. Notes

Subagent dispatch cost ~150-200K is the dominant budget item; main session orchestration is ~30-45K. PLAN sessions are the most token-efficient per LOC-shipped if subagent does the heavy lifting.
