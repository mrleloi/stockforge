# /master-plan — High-Level Work Decomposition

> Invoke `master-planner` subagent (fresh context, run_in_background) to decompose a goal into phased, budgeted sessions following the sandwich pattern.

## When to Use

- Start of new phase
- When a large goal needs breakdown
- When plan has >10 tasks and needs splitting
- When approaching unfamiliar territory

## Input

`$ARGUMENTS` — goal or objective to decompose (e.g., `implement Phase 1 thin slice`, `build KOL channel monitoring pipeline`).

## Process

1. **Pre-flight** — identify scope (phase-level vs feature-level). Check `agent-workspace/session-plans/pending/` for overlap. Ensure spec exists for what's being planned (or planning will produce one).

2. **Dispatch `master-planner` subagent** with: goal description, `PROJECT_CHARTER.md`, `AGENT_OPERATING_MANUAL.md` (phases / sandwich / budgets), relevant `agent-workspace/constitution/` files, `current-execution.md` (phase alignment), recent session logs (pace calibration). Subagent budget: 20-30K context + 10-15K output.

3. **Subagent decomposes** — break into logical units with dependencies; group related work; separate PLAN from IMPL (sandwich pattern); identify THESIS sessions separately. Per-unit: estimate context budget via `agent-workspace/constitution/session-budgets.md` formula; pick session type (PLAN / FOCUSED_IMPL / MULTI_TASK_IMPL / VERIFY / RECOVERY / THESIS / INGEST / POST-MORTEM); list critical files. Verify no session > 250K hard cap, no session mixes PLAN+IMPL.

4. **Identify verification points** — where to insert VERIFY sessions (sandwich), human gates, drift-check runs.

5. **Subagent writes** per-session plans to `agent-workspace/session-plans/pending/NNN-name.md` using SPEC_TEMPLATE-style schema: Meta (spec/feature, session_type, prerequisites, agent) / Goal (verifiable success criteria) / Context Budget (fixed + variable + working = total) / Context to Load (constitution + specific) / Task Breakdown (numbered with verification check per task) / Verification (deterministic gates + specific checks) / Handoff to Next Session / Risks.

6. **Master-plan summary** — overview row showing Goal / Estimated duration / Phase / Session sequence table (`# | Title | Type | Budget | Depends on`) / Critical Path / Parallel Opportunities / Sandwich Structure (Architect-Dev-Verifier rotation) / Risks-Contingencies / Files Written.

7. **Review with user** — session boundaries logical? Budgets realistic? Missing work? Sequence makes sense? Adjustments before commit.

8. **Update `current-execution.md`** — append to active work items; set session 1 as next pickup.

## Anti-Patterns

- Planning more than one phase at a time (too speculative)
- Mixing PLAN + IMPL in one session (catastrophic — Session 4 failure mode)
- Assuming sessions can exceed 250K "if careful" (quality cliff is real)
- Skipping verification sessions (cumulative drift)
- Mixing THESIS with IMPL (THESIS is read-only on code per CLAUDE.md)

## Do

- Right-size sessions (not too big, not too many small)
- Plan recovery sessions for risky work
- Identify parallelizable sessions for flexibility
- Keep session plans in git (review-able, diff-able)

## Related

- `master-planner` agent — does the actual decomposition
- `agent-workspace/constitution/session-budgets.md` — budget formulas (fixed + variable + working)
- `SPEC_TEMPLATE.md` — session plan schema source
- `/session-start` — picks up the produced plans
