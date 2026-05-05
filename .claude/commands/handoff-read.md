# /handoff-read — Lightweight Last Session Load

> Quick version of session-start when you don't need full ceremony.

## When to Use

- Continuing work from session that ended recently
- Want fast context without full state load
- Know exactly what you want to do, just need pickup context

Use `/session-start` instead when:
- Starting fresh work
- Unclear what to work on
- Need to confirm phase/alignment

## Steps

### 1. Read Last Session Log

Find newest file in `agent-workspace/memory/sessions/`.
Read specifically the "Next Session Pickup" section.

### 2. Read Current Execution

Quick glance at `agent-workspace/memory/current-execution.md`:
- Active phase
- Current work item
- Any blockers

### 3. Output Minimal Context

```markdown
# Pickup from Last Session

## Last Session
[N] — [date]
Goal was: [from log]
Left off at: [pickup note]

## Active Work
[From current-execution.md]

## Immediate Next Action
[Specific next step from pickup note]

Ready to continue?
```

### 4. Wait for Confirmation

Don't proceed until user confirms or adjusts direction.

---

## Contrast with /session-start

| Aspect | `/session-start` | `/handoff-read` |
|---|---|---|
| Context loaded | Full (memory + project + 3 sessions) | Minimal (last session only) |
| Budget used | ~5-10K | ~1-2K |
| Output | Full session brief | Minimal pickup note |
| Use when | Fresh/unclear | Continuing known work |

Use the right tool — unnecessary context is waste.
