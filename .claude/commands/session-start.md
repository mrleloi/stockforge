# /session-start — Begin Work Session

> Loads project context, identifies session type, outputs session brief. Body delegates loading discipline to `agent-workspace/CLAUDE.md` § Reading Priority + `agent-workspace/constitution/session-budgets.md` § decision tree.

## When to Use

At the start of every meaningful work session with Claude Code.

## Input

Optional: `$ARGUMENTS` — session goal (e.g., `implement KOL channel crawler`, `thesis on VCB`). If no goal, infer from `current-execution.md` or ask.

## Steps

1. **First-session check** — if `current-execution.md` shows Phase 0 + Session N=1, jump to "First Session Handling" (delegate to `docs/DAY_1_CHECKLIST.md`).

2. **Load project state** in priority order (per `agent-workspace/CLAUDE.md` § Reading Priority):
   - `agent-workspace/memory/current-execution.md` (active track)
   - `agent-workspace/memory/project.md` (project state)
   - `agent-workspace/memory/checkpoints/latest.md` if recent (within 24h)
   - `agent-workspace/memory/agent-notes.md` (learned rules)
   - `agent-workspace/memory/mistake-log.md` (failure catalog)
   - Last 3 files in `agent-workspace/memory/sessions/`
   - Pattern files in `agent-workspace/memory/patterns-discovered/` matching goal keywords

3. **Determine session type** via `agent-workspace/constitution/session-budgets.md` decision tree:
   - No detailed plan exists → **PLAN** (sandwich-architect subagent)
   - Plan exists, 1-3 small tasks → **FOCUSED_IMPL**; 4-10 → **MULTI_TASK_IMPL**; >10 → recommend split
   - Previous session failed/broken → prepend **RECOVERY**
   - Need to verify previous session output → schedule **VERIFY** after main work
   - Goal is investment thesis on a stock → **THESIS** (read-only on code; outputs to `thesis-log/`)
   - Goal is data ingest / KOL channels → **INGEST**
   - Goal is reviewing past thesis outcomes → **POST-MORTEM**

4. **Estimate context budget** per `session-budgets.md` formula: `fixed (~12K)` + `BCs needed × 5K` + `specs × 3-4K` + `files × 2K` + `skills × 1.5K` + `working space (~30%)`. If > 250K → flag, recommend split.

5. **Match session plan** — look in `agent-workspace/session-plans/pending/` for goal match. Load if found; otherwise note need to run `/master-plan`.

6. **Output session brief** (see "Brief Schema" below).

7. **Wait for user confirmation** — do NOT begin substantive work until user confirms or adjusts.

## Brief Schema

```markdown
# Session Brief — [DATE] Session N

## Goal
[One sentence]

## Session Type
[PLAN | FOCUSED_IMPL | MULTI_TASK_IMPL | VERIFY | RECOVERY | THESIS | INGEST | POST-MORTEM]

## Context Budget Estimate
- Fixed overhead: X K / Variable: Y K / Working: Z K → Total: T K (of 250K cap)

## Status Check
- Active phase: [from current-execution.md]
- Recent sessions (last 3, one-line each)
- Pending from last session (if any)

## Files Loaded / Skills Relevant / Constraints Active
[Lists; THESIS sessions cite adversarial-by-default + I-S1 no-LLM-math + I-S10 bear-case-required]

## Proposed Next Actions
1. ... 2. ... 3. ...

Ready to proceed? Confirm or adjust.
```

## First Session Handling

If Phase 0 + Session 1: output a welcome that frames Day 1 as a checklist and delegates to `docs/DAY_1_CHECKLIST.md` (read charter, skim AOM, customize architecture, run `/drill-me` to seed glossary, identify 3-5 VN stocks for eval set). Offer 3 choices: (A) walk Day 1 checklist, (B) jump to first spec review, (C) explore codebase first. Wait for user choice.

## Error Handling

- Memory file missing/corrupted → report specifically, don't guess
- Constitution file missing → CRITICAL, don't proceed
- `current-execution.md` contradicts `project.md` → flag for human resolution
- Budget estimate > 250K → recommend split before starting

## Anti-Patterns

- Skipping memory file reads "to save time" (costs more later)
- Loading entire codebase upfront (use just-in-time per `CLAUDE.md` § P3)
- Guessing session type (follow decision tree)
- Proceeding without user confirming brief
- Starting THESIS and writing code (THESIS is read-only on code per CLAUDE.md)

## Related

- `agent-workspace/CLAUDE.md` § Reading Priority — the canonical load order
- `agent-workspace/constitution/session-budgets.md` — budget formulas + decision tree
- `/master-plan` — produces session plans this command picks up
- `/session-end` — pair partner for closing sessions
