---
observation_id: sandwich-architect-S345-stop-hook-perf-plan
type: architect-plan-handoff
created_at: 2026-05-16T~21:00 SEAST
author: sandwich-architect subagent (background dispatch S345; Opus 4.7)
plan_id: 023-S346-stop-hook-perf-quick-wins
target_dev_session: S346
target_verify_session: S347
parent_session: main session (S343-S344-close) per user ratification "follow your recommendation" + "run full autonomous" 2026-05-16T~20:30 SEAST
budget_used: ~30-45K Opus PLAN (within 50-70K cap)
plan_file: agent-workspace/session-plans/pending/023-S346-stop-hook-perf-quick-wins.md
---

# sandwich-architect S345 observation — plan-023 stop-hook performance quick wins

## TL;DR

Authored plan-023 (~900 LOC) translating observation `2026-05-16-stop-hook-performance-audit.md` empirical findings into executable sandwich-dev recipe. 6 sub-tracks (D1..D6) + 7 DDs + 8 AQs pre-answered + 28 DoD items + 8 RMs. Architectural A1-A4 explicitly DEFERRED to plan-027a..e successors with AP-7 named triggers. Phase-status-coherence regex limitation surfaced at S343-S344 row included as D4 sub-track (extends regex + adds letter→numeric mapping table).

Budget recommendation: 80-120K Opus FOCUSED_IMPL for S346 dev. Sonnet acceptable if STEP 0 stays clean.

## VBW protocol compliance

All 6 affected hooks Read end-to-end (NOT from memory) before plan authoring:
- `scripts/hooks/atomic-write-check.sh:1-301` (claim_file_slot @ :146-156; find-delete @ :149)
- `scripts/hooks/python-determinism-check.sh:1-253` (claim_file_slot @ :66-76; find-delete @ :69)
- `scripts/hooks/path-safety-check.sh:1-333` (claim_file_slot @ :163-171; find-delete @ :165)
- `scripts/hooks/html-separator-check.sh:1-258` (claim_file_slot @ :84-92; find-delete @ :86)
- `scripts/hooks/bash-hook-lint.sh:1-523` (10 checks across :44-491; 108-hook iteration confirmed)
- `scripts/hooks/phase-status-coherence.sh:1-239` (regex @ :84 numeric-only confirmed)

Predecessor observation Read in full: `agent-workspace/memory/observations/2026-05-16-stop-hook-performance-audit.md:1-146`.

Cross-reference Read: plan-021 + plan-022 for cadence + sandwich-dev observation format + plan-021 D7 dispatch-template-improvement context. project.md row 4 + current-execution.md S343-S344 row to confirm letter-phase context for D4.

## Architecture decisions (DD-1..DD-7) — pre-answered

- **DD-1 Hoist-vs-batch**: PICK hoist (simplest; matches observation P1 directly; reserve cache-based for plan-027b)
- **DD-2 Cool-down marker name**: PICK per-hook (no cross-hook coupling; Karpathy P3 surgical)
- **DD-3 Cool-down duration**: PICK 600s fixed (debounce-friendly; matches observation P2)
- **DD-4 bash-hook-lint fix**: STEP 0.3-dependent. Architect expectation: (a) content-hash early-exit. Alternatives: (b) xargs-P4 parallelization | (c) single-check tighten | (d) wall-budget kill switch + plan-027a deferral
- **DD-5 phase-status regex**: PICK extend regex + add letter→numeric mapping table (case statement covering A-E + F-prime/G-prime/H-prime → 4); resolves IN_PROGRESS comparison without project.md schema change
- **DD-6 .severity-state.tsv schema**: N/A this plan (plan-024 territory)
- **DD-7 Fire-test strategy**: PICK per-hook (5 NEW or extended fire-tests; 1 NEW phase-status-coherence-fire-test.sh + 4 extensions)

## STEP 0 procedure

6 sub-steps, each with explicit STOP-AND-ASK trigger:
1. Verify observation file path + re-time atomic-write-check.sh empirically (target ≥30s confirms baseline; <5s = pre-patched → STOP)
2. Verify all 4 .py-scan hooks share claim_file_slot pattern (per-hook marker prefix grep)
3. Diagnose bash-hook-lint root cause via single timing + dominant-check identification (DD-4 PICK gated here)
4. Verify phase-status regex limitation empirically (sed against 3 sample headers — numeric, letter, letter-prime)
5. Inventory existing markers (363+363+363+161 ≈ 1250 expected per observation; AQ-5 keep-don't-migrate decision)
6. STEP 0.10 baseline (commit SHA + 6 file SHAs; F4 carry-forward from plan-021 dispatch-template-improvement)

## Coordination paths (sandwich-dev's in-scope file list)

11 files in-scope: 6 hook source files + 5 fire-test files (4 extensions + 1 NEW) + 3 memory files (current-execution.md / sessions/S346.md / observations/sandwich-dev-S346-*.md) + plan mv at close.

Off-limits enforced via § J: `.claude/settings.json` Stop chain ordering (A4 deferred), PROJECT_CHARTER.md, constitution/**, project.md (no Phase Goals Tracker change per AQ-6), the other 47 Stop chain hooks, any Python under packages/apps, obsidian-vault/raw/**.

## Budget recommendation

80-120K Opus FOCUSED_IMPL. Sonnet acceptable if STEP 0.3 picks DD-4 (a) AND D4 mapping stays small AND no STOP-AND-ASK. MULTI_TASK escalation triggers documented (RM6 STOP-AND-SPLIT pattern from plan-020).

## Harness anomalies noted during architect VBW

1. **phase-status-coherence:84 silent false-positive** (~25 sessions S323-S342) — INCLUDED in plan as D4. Surgical workaround at S343-S344 row removed by D4 close.
2. **No phase-status-coherence-fire-test.sh exists** per Glob 2026-05-16 — Charter v1.1 Principle 11 violation by omission (this hook shipped without companion fire-test). INCLUDED in plan as D5 (NEW fire-test creation).
3. **Frontmatter inconsistency** noted in observation: 2 of 3 source hooks' notification files have NO `level:` frontmatter (per S341 D1 commit's content-hash dedup + level-WARN addition); python-determinism-check.sh + path-safety-check.sh DO have `level: WARN` post-S341 D1; atomic-write-check.sh:280 has only `status: pending` (no `level:`). This is an orthogonal observation; NOT in plan-023 scope; surface in S346 observation for plan-024 backlog if it continues to cause severity-classifier classification noise.
4. **bash-hook-lint Check 1 already supports skip-marker** (per :50-51 `bash-hook-lint:allow L-S11-1`) — this pattern is reusable if D3 PICK = (c) single-check tighten.

## Compliance attestation

- harness_priority_one ✓ (this IS harness work; ranked above S345 NDH verifier dispatch + Phase D continuation)
- VBW protocol ✓ (all 6 hooks + predecessor observation + project.md + current-execution.md + 2 plan files Read fresh)
- AP-1 ✓ (fresh-context architect dispatch from S345 main; architect did NOT review own work; this is plan output for fresh-context sandwich-dev S346)
- AP-7 ✓ (every DEFER cites successor + revisit trigger; A1-A4 → plan-027a..e with named gates)
- AP-23 ✓ N/A this plan (no ritual-demotion candidates; quick-win patches are 1st-instance harness fixes)
- Karpathy P3 ✓ (every recommendation traces to observation findings + phase-status anomaly; § J coordination paths enforces surgical scope)
- 0 charter writes ✓ (PROJECT_CHARTER.md not touched)
- 0 constitution writes ✓ (`agent-workspace/constitution/**` not touched)
- 0 production code ✓ (architect PLAN-only; no Python, no hook source edits)
- D-060 status: architect MAY commit own plan output per `sandwich-architect.md` D7 update (post-S341); main session orchestrator decides whether architect or main commits this PLAN output per dispatch-template pattern (architect's recommendation: main commits to maintain D-060 + S342 close pattern consistency; if architect's subagent harness grants Bash + git commit, architect may self-commit per S342 D7 update)
- pre_flight_active ✓ (R1+R2+R3 all active; BEHAVIORAL HOLD § (1) acknowledged — no sync-grilling cadence in plan)

## Estimated next-session token budget

S346 sandwich-dev: 80-120K Opus FOCUSED_IMPL (per § K). 
S347 sandwich-verifier: 30-50K Opus VERIFY (per AP-1 standard verifier budget).

## Files created this architect dispatch

1. `agent-workspace/session-plans/pending/023-S346-stop-hook-perf-quick-wins.md` (~900 LOC)
2. `agent-workspace/memory/observations/sandwich-architect-S345-stop-hook-perf-plan.md` (this file; ~150 LOC)
