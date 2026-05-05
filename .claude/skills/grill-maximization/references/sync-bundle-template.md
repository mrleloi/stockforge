# Sync-Bundle Template — Specialized Q&A for "Are We Still Aligned?"

> Specialized Q&A template for periodic sync-grilling rounds. Differs from feature/scope grill:
> questions verify shared understanding rather than propose new direction.
> Created S7 (2026-04-29) per Track 5.5b.4 (D-003 § 5.5b.4).
> Pairs with `sync-grilling-trigger.sh` SessionStart hook (Track 5.5b.3).

---

## When to use this template

Use when ANY of:
- `sync-grilling-trigger.sh` emits SYNC-GRILLING DUE in additionalContext
- ≥3 items in `sync-state.md` have `state: assumed-aligned` for >7 days without re-confirmation
- ≥1 item in `sync-state.md` has `state: open-question` blocking active track
- Phase boundary about to fire (post-Phase-N close, pre-Phase-(N+1) entry)

Do NOT use when:
- All sync-state items are `confirmed-aligned` and recent (<7 days)
- Active track requires immediate scope-tier or charter-tier decisions (use feature/scope grill instead)

---

## Composition rules (BINDING per UP-06 NO-Silent-Default)

1. **Source items only from `agent-workspace/memory/sync-state.md`**. Do NOT invent new sync questions ad-hoc — those belong in feature/scope grill.

2. **Phrase every question as alignment check**, not new direction. Patterns:
   - ✅ "Do we still understand X the same way?"
   - ✅ "Has Y changed since we last confirmed it on {date}?"
   - ✅ "Is Z still the operational policy, or has practice diverged?"
   - ❌ "Should we change X?" (this is feature/scope, not sync)
   - ❌ "What direction for Y?" (open-question, not alignment check)

3. **Each question MUST cite exactly ONE sync-state item ID** (sync-NNN). Multi-item questions get split.

4. **Multi-batch protocol**: max 4 questions per `AskUserQuestion` call. Bundle of N>4 sync items → ceil(N/4) batches across same session or sequential turns. NEVER use file-only-with-default-acceptance fallback (UP-06 hard rule).

5. **Each option = single explicit pick**:
   - Option A: "Yes, still aligned — confirmation re-stamp"
   - Option B: "No, my understanding has shifted — let me explain (other answer)"
   - Option C (only when applicable): "Partially — still aligned on X but Y has changed"
   - NEVER use vague labels like "I'm not sure" or "default applies after 24h"

6. **Closure protocol**: after answers received:
   - If A → update sync-state.md item `state: confirmed-aligned`, `confirmed_at: <today>`, `confirmation_via: AskUserQuestion sync-grill <date>`
   - If B → transition `state: open-question`, append `gap_note: <user explanation>`, queue follow-up via `queued-grill-master.md` with explicit `fire_when:` trigger
   - If C → split into two items; one confirmed, one open-question

---

## Bundle skeleton (use as-is, fill blanks)

```markdown
## Sync Bundle — <YYYY-MM-DD> (S<N>)

**Trigger**: <sync-grilling-trigger.sh fired | manual | phase-boundary>
**Last sync check**: <date from sync-state.md>
**Items checked this round** (N=<count>): sync-<id1>, sync-<id2>, ...

### Q1 — sync-<NNN>: <statement from sync-state.md>
**Original confirmation date**: <date>
**Original basis**: <decision/AskUserQuestion ref>

Question: "Do we still understand <thing> the same way as <date>?"
Options:
- A: Yes, still aligned (confirmation re-stamp)
- B: No, my understanding has shifted — let me explain
- C (if applicable): Partially aligned — see notes

### Q2 — sync-<NNN>: ...
[same format as Q1]

### Q3 — sync-<NNN>: ...
[same format]

### Q4 — sync-<NNN>: ...
[same format]
```

---

## Anti-patterns to avoid

| Anti-pattern | Why bad | Correct |
|---|---|---|
| Mix sync + scope questions in same bundle | UP-06 charter-tier split rule (mixing dilutes alignment signal) | Separate bundles |
| Question without `sync-NNN` reference | sync-state.md becomes drift-prone | Always cite item ID |
| Ask 8+ sync questions in one batch | AskUserQuestion 4-limit + cognitive overload | Multi-batch |
| Use file-only "answer by editing this file" fallback | UP-06 silent-default rule | AskUserQuestion is PRIMARY |
| Omit `confirmation_via:` field on update | Lose audit trail | Always cite the AskUserQuestion turn |

---

## Worked example (4-question round, derived from sync-state.md current state)

```
## Sync Bundle — 2026-05-10 (S10, post-Track 6 entry)

**Trigger**: sync-grilling-trigger.sh fired (4 sessions since last check; threshold=3)
**Last sync check**: 2026-04-29
**Items checked this round** (N=4): sync-002, sync-008, sync-015, sync-021

### Q1 — sync-002: "Phase 0 = Harness Bootstrap, supervised until Track 7"
**Original confirmation date**: 2026-04-29 (D-003 Round 1+2)
Question: "Do we still understand Phase 0 as supervised-until-Track-7, or has the autonomous
boundary shifted given S6-S9 progress?"
Options:
- A: Yes, supervised through Track 7 (S11) as confirmed
- B: No, ready to flip autonomous earlier — explain when
- C: Partially — autonomous for {scope} but supervised for {scope}

### Q2 — sync-008: "..."
[same format]
```

---

## Wiring with grill-maximization skill

Add this section to `.claude/skills/grill-maximization/SKILL.md` (manual edit per Track 6 progressive-disclosure refactor):

```markdown
## Sync Bundle Composition (Track 5.5b.4)

For periodic alignment rounds, use `references/sync-bundle-template.md`:
- Trigger: `sync-grilling-trigger.sh` SessionStart hook
- Source: items from `agent-workspace/memory/sync-state.md`
- Phrasing: alignment checks, not new directions
- Limit: 4 questions per `AskUserQuestion`; multi-batch for N>4
- Closure: update sync-state.md `state` + `confirmed_at` after answers
```
