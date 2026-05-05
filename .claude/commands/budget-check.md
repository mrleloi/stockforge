# /budget-check — Current Session Token Budget Status

> Report current session context consumption and project against budget. Body delegates budget formulas + thresholds to `agent-workspace/constitution/session-budgets.md` (canonical).

## When to Use

- Every ~30 minutes during long sessions
- Before starting a major new subtask
- When feeling context might be bloating
- Before loading large new files

## Process

1. **Estimate current consumption** — sum of file reads + LLM responses + tool outputs + fixed overhead (CLAUDE.md + skills + constitution). Claude Code doesn't expose exact count, so estimation is practical. Use `.transcript-tokens` if available (per Track 8/9 telemetry).

2. **Identify session type budget** — PLAN 80K / FOCUSED_IMPL 150K / MULTI_TASK_IMPL 250K / VERIFY 60K / RECOVERY 150K / THESIS 100K / INGEST 80K / POST-MORTEM 50K. Universal hard cap: 250K.

3. **Project remaining work** — given current position in session plan: tasks remaining × estimated tokens per task → total remaining.

4. **Compute status** — `usage_pct = estimated_used / budget_limit` ; `projected_total = estimated_used + estimated_remaining` ; `projection_pct = projected_total / budget_limit`.

5. **Output status report** with sections: Current Session (type / started / elapsed) / Estimated Consumption (fixed + files + tool outputs + agent responses → total) / Budget Status (session budget / used / remaining + percent) / Projection (tasks still to do / avg per task / projected additional / projected total) / Status (GREEN / YELLOW / RED / OVER) / Recommendations.

6. **Threshold actions** — `< 50%` normal proceed; `50-70%` caution, avoid unnecessary loads; `70-85%` finalize current task, no new major tasks; `> 85%` immediate handoff prep; `> 100% or > 250K` hard stop, emergency session end.

7. **Hard cap enforcement** — if projected to exceed 250K (universal cap regardless of session type), output WARNING: BUDGET BREACH IMMINENT — projected total / 250K cap / cite Session 4 (300K+ tokens, 0 tasks completed) as measured evidence. Required action: stop at safe checkpoint, save state to session log, split remaining work to new session. Do NOT continue past 250K without explicit user override.

## Observable Signals of High Usage

Even without an exact count, these suggest high context:

- Difficulty remembering early conversation
- Re-reading files already read
- Agent asking questions answered earlier
- Responses getting shorter / less coherent

If observed → run `/budget-check` immediately.

## Cost Awareness

Budget isn't just quality — it's money. Claude Opus ~$15/M input tokens; Claude Sonnet ~$3/M; 250K session ≈ $3.75 (Opus) or $0.75 (Sonnet) per input pass. Keep sessions focused → cost stays reasonable.

## Integration

- Auto-check embedded in `/session-verify`
- Manual check via this command
- Hard-stop logic via `scripts/hooks/budget-watchdog.sh` (per CLAUDE.md context-threshold band: 180K wind-down / 220K cliff / 250K hard cap)

## Anti-Patterns

- Continuing past 250K because "I'm almost done" — quality degrades sharply ("lost in middle" effect; Session 4 evidence)
- Skipping check on long sessions
- Treating budget as advisory not enforcement

## Do

- Run periodically during long sessions
- Treat 250K as hard ceiling, not soft
- Wrap up cleanly when projected over budget — emergency handoff is more expensive than a clean split

## Related

- `agent-workspace/constitution/session-budgets.md` — canonical budgets per session type + thresholds
- `scripts/hooks/budget-watchdog.sh` — automated wind-down / cliff / hard-cap signals
- `/session-verify` — pairs with this command
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv` — observed token usage per session (per S19 aggregator)
