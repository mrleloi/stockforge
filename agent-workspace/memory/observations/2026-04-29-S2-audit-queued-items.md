---
observation_id: 2026-04-29-S2-audit-queued-items
type: queued-amendments-from-audit
session: S2
related_audit: agent-workspace/memory/drift-logs/2026-04-29-S2-audit.md
created_at: 2026-04-29
status: open
---

# Queued Amendments — From S2 Drift Audit

These items surfaced in the adversarial drift audit and are NOT immediately fixable in S2 (require schema/spec changes that belong in later tracks). Tracking here so they're not lost.

## G1 — Re-grill Q-S5 in S5 (Track 7)

**Original issue**: Q-S5 ("small trusted circle = git-fork single-tenant" identity-tier) was bundle-absorbed via "ok continue" alongside 4 SCOPE-tier items in Round 3.

**Where to action**: S5 — when `agent-workspace/proposals/identity-scope.md` (Track 7 deliverable) is composed and promoted to `constitution/identity-scope.md`.

**Required action**:
1. Compose a CHARTER-tier bundle with 1-3 questions ONLY about identity-scope:
   - "Confirm: stockforge IS single-tenant Phase 0-5; multi-tenant requires re-charter at Phase 6+. Y/N?"
   - "Confirm: 'small trusted circle' = git-fork distribution to ≤5 named peers; not subscription/SaaS distribution. Y/N?"
   - "Confirm: identity NOT-list (D-002 § F) is binding for Phase 0-5; amendments require new charter prompt drop. Y/N?"
2. Set `priority: URGENT`, ALERT notification mandatory.
3. Each question is explicit-pick (no safe agent-defaults, no `D: open answer` shortcut).
4. After answered: append to D-002 `approval_chain` with `actor: user`, `action: ACCEPTED-CHARTER-EXPLICIT`, plus quoted user phrase.
5. Promote `proposals/identity-scope.md` → `constitution/identity-scope.md` ONLY after explicit acceptance.

**Owner**: Whoever runs S5.

---

## B1 — Track 8a Success Criteria Amendment

**Original issue**: D-002:158-168 Track 8a success criteria only test write-path of Confidence Score. Doesn't test "agent's NEXT decision routes differently after a score update" — the "live, not tracking-logs" requirement from UP-03 Q5.

**Where to action**: S6 (Track 8a implementation).

**Required action**: Add to D-002 § Track 8a § Success criteria:

> 4. **Live consumption test**: Before Track 8a smoke test, take baseline reading of agent decision-routing on a representative SCOPE-tier prompt (record: which subagent was dispatched / which Q&A was opened / which decision template was filled). Lower the Confidence Score for `SCOPE` category by 0.3 (simulated drift). Re-run identical prompt. **Pass criterion**: agent's NEXT decision-routing changes — e.g. now opens a Q&A bundle that wasn't opened in baseline, or escalates a level higher. If routing identical → fail; the Confidence Score is write-only, not "live".

This validates UP-03 Q5: "score đó phải LIVE chứ không phải thu thập xong để đó như tracking logs".

**Owner**: S6 implementer.

---

## G2 — Pre-Amendment Delta Summary Protocol

**Original issue**: REV-2 added 30+ amendments + budget delta 940K → 1.3M tokens (+38%). User saw the questions Q-S1..Q-S5; did NOT see explicit "delta summary" surfacing the magnitude before "ok continue".

**Where to action**: S5 (Track 7 — `agent-workspace/proposals/decision-discipline.md` per D-002:309 REV-2 amendments § Track 7).

**Required protocol** (codify in `decision-discipline.md`):

> ### Pre-Amendment Delta Surface Rule (Rev-N approval gate)
>
> Before requesting user approval for any REV-N that would:
> - Add ≥10 amendments to a previously ACCEPTED decision, OR
> - Increase budget envelope by ≥25%, OR
> - Add a new track / sub-track, OR
> - Change phase-numbering or sequencing,
>
> the agent MUST author and surface a "Delta Summary" in the Q&A bundle headline section:
>
> ```markdown
> ## REV-N Delta Summary
> - **Amendments added**: <count> (categorized: <ADD-N / REFINE-N / SPLIT-N>)
> - **Budget delta**: <old> → <new> (<+%>)
> - **Sequencing delta**: <session count old> → <new> (<+/- N sessions>)
> - **Track delta**: <added / split / merged>
> - **What this commits user to**: <one sentence>
> - **What user can still revert**: <list>
> ```
>
> User-facing notification (`human-workspace/notifications/N-<TS>-AMENDMENT-<slug>.md`) MUST include this delta summary verbatim.

**Owner**: S5 (Track 7).

---

## DR-CONFIG — LOC Ceiling Enforcement Hook

**Original issue**: REV-2 specifies LOC ceilings (200 agents / 150 skills / 120 commands) but no hook enforces. Track 6 `validate_skills.py` scheduled for S4 — but in the meantime agents can drift (as happened with `qa-escalation` 242 LOC and `grill-maximization` 187 LOC, only caught in adversarial audit).

**Where to action**: S3 (Track 5 — add to hook list).

**Required action**: Add to S3 task list:

```
[ ] scripts/hooks/loc-ceiling-check.sh — PostToolUse on Write/Edit to .claude/{agents,skills,commands}/**/*.md
    - wc -l the file
    - if >ceiling: append warning to .session-hooks.log AND agent-workspace/memory/drift-logs/<TS>-DR-CONFIG.md
    - exit 0 (warn-only) by default
    - if env STOCKFORGE_LOC_STRICT=1, exit 1 (block)
    - Ceilings: agents=200, skills=150, commands=120
```

This is the deterministic backstop until Track 6 ships full validator.

**Owner**: S3 (Track 5).

---

## How These Items Get Closed

1. When the owner-track session begins, the agent reads this observation FIRST.
2. The amendment is performed in-place per the "Required action" section.
3. After completion, this observation is updated: `status: open` → `status: closed`, with `closed_at` and `closed_in_session` fields.
4. A line is appended to `agent-workspace/memory/drift-logs/2026-04-29-S2-audit.md` cross-referencing the closure.

If an item drifts past 2 sessions without being closed, it counts as `defer_cycles += 1` against D-002 (R7 mitigation).
