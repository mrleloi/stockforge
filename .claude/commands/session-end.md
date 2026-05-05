# /session-end — Close Work Session

> Persists state, writes session log, prepares handoff for next session. Body delegates load-priority discipline to `agent-workspace/CLAUDE.md` § Session Protocol.

## When to Use

At the end of every meaningful work session. **Not optional** — skipping breaks continuity (session N+1 SessionStart hook reads checkpoints + sessions/).

## Steps

1. **Summarize work done** — review goal (from session brief), what accomplished, what blocked/unresolved, any surprises.

2. **Write session log** at `agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md` per the schema below.

3. **Update `agent-workspace/memory/project.md`** if any of: architectural decision made, phase boundary reached, major TODO added/completed, known issue surfaced, invariant needs adjustment. Otherwise no change.

4. **Update `agent-workspace/memory/current-execution.md`** (routing source-of-truth) — work completed → move to Archived; progressed → update Status; blocked → add Blocker info; new starting → add to Current Work Items; bump "Session N" number.

5. **Capture learned rules** — did anything go wrong a rule would prevent? Discover a pattern worth formalizing? Anti-pattern to flag? If yes, append to `agent-workspace/memory/agent-notes.md` using its existing entry format.

6. **Capture patterns** — if a useful pattern emerged that might be reused: dedicated file under `agent-workspace/memory/patterns-discovered/`? Or upgrade to a skill in `.claude/skills/`?

7. **Thesis log (THESIS sessions only)** — ensure entry in `agent-workspace/memory/thesis-log/YYYY-MM-DD-[ticker].md` containing ticker, date, bull case, bear case, catalysts, risks, calibration note. **No single buy/sell verdict** — output is multi-criteria trade-off matrix per I-S35.

8. **Run drift check (recommended if code changed)** — `/drift-check` to catch issues before next session.

9. **Stage changes** — `git add -A; git status`. Report what's staged. **Do NOT commit unless user explicitly requested** (CLAUDE.md hard rule).

10. **Output session-end summary** — 2-3 sentence summary / Files Changed / Memory Updated (project.md / current-execution.md / session log / agent-notes.md / thesis-log) / Quality Status (deterministic gates / test status / drift signals) / Next Session Pickup (specific instruction) / Staged for Commit (`git status` output) — closing with: "Staged but not committed. Run `git commit` when ready, or let me know if you want me to commit."

## Session Log Schema

Required sections in `sessions/YYYY-MM-DD-session-N.md`: `Goal` / `Session Type` / `Context Budget` (estimated vs actual + tasks-per-100K efficiency) / `Approach` (2-3 sentences) / `Accomplished` / `Blocked / Unresolved` / `Learned Rules` / `Patterns Noticed` / `Files Modified` (`git diff --name-only`) / `Next Session Pickup` (specific) / `VBW Protocol Adherence` (per checkpoint applied/not) / `Quality Gates Status` (deterministic / probabilistic / human) / `Thesis Log` (if THESIS — ticker + verdict-summary line + path).

## Error Handling

- Cannot write session log (disk/permissions) → CRITICAL, report specifically
- `project.md` conflicts with `current-execution.md` → flag for resolution
- Deterministic gates fail → do NOT claim success; report honestly per CLAUDE.md (Tier 1 must pass before commit)

## Anti-Patterns

- Skipping this command "to save time" — session N+1 SessionStart hook depends on it
- Writing session log without actually reviewing the work
- Updating `project.md` automatically when nothing significant happened
- Committing without user approval (CLAUDE.md hard rule — agent stages, user commits)
- Claiming completion if Tier 1 gates failed
- Skipping thesis-log update for THESIS sessions (calibration system depends on it per Charter Principle 8)

## Related

- `/session-start` — pair partner; reads what this command writes
- `agent-workspace/CLAUDE.md` § Session Protocol — canonical close-down sequence
- `agent-workspace/memory/checkpoints/latest.md` — separate handoff artifact also written at session close
- `/drift-check` — invoked at step 8
