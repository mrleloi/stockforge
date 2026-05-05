# Post-Mortem — Self-Awareness Loop + Promotion Cycle Skipped Since S19

**Date**: 2026-05-01
**Surfaced by**: User audit prompt during S34-extension turn (post-checkpoint, ~269K tokens)
**Severity**: HIGH (meta-loop dead → drift compounds invisibly across sessions)

---

## What was supposed to be running continuously

Per S15 Track 7 + S19 Track 9 (Self-Awareness build):
- `agent-workspace/memory/mistake-log.md` — 1 entry per failure / drift / user correction per session
- `agent-workspace/memory/self-awareness/known-issues.md` — KI cards with reproducer + workaround + fix-target
- `agent-workspace/memory/self-awareness/best-practices.md` — BP cards distilled from successful patterns
- `agent-workspace/memory/self-awareness/profile-template.md` — 1 profile card per (model, effort, task_class) tuple per session
- `sessions-rollup.tsv` — auto-fire by `self-awareness-aggregate.sh` Stop hook
- `agent-workspace/proposals/*.md` → promotion cycle: at phase boundary, run promote-rule subagent to decide which proposals graduate to `agent-workspace/constitution/` or `scripts/hooks/`

Per CLAUDE.md § Session End (5 steps):
1. Update `project.md` if architectural decisions
2. Write `sessions/YYYY-MM-DD-session-N.md`
3. Update `current-execution.md`
4. If learned rule emerged → append to `agent-notes.md`
5. Thesis-log entry if applicable

→ Step 4 ✅ done. Step 1/2/3 ✅ done. **Steps tied to Track 9 (mistake-log + KI/BP cards + profile cards) NOT in CLAUDE.md § Session End checklist** — implicit from Track 9 spec but never codified into Session-End ritual.

---

## What actually happened S20-S34 (15 sessions)

### Self-awareness artifacts (file mtime evidence)

| Artifact | Last touch | Status |
|---|---|---|
| `mistake-log.md` | Apr 29 20:37 (S19) | DEAD — no M-S20..M-S34 entries |
| `known-issues.md` | Apr 29 23:54 (S19) | DEAD — only KI-001/002/003 seeds |
| `best-practices.md` | Apr 29 23:54 (S19) | DEAD — only BP-001/002/003 seeds |
| `profile-template.md` | Apr 29 23:53 (template only) | NEVER USED — 0 populated cards |
| `sessions-rollup.tsv` | May 1 07:08 ✅ | LIVE — bash hook auto |
| `agent-notes.md` | regular updates | LIVE — manually appended |

### Promotion cycle artifacts

- `agent-workspace/proposals/` = 9 files (autonomous-protocol, decision-discipline, memory-tiers, provenance-protocol, financial-data-protocol-amendment ×2, invariants-amendment-VN, architecture-amendment, session-budgets-amendment)
- `agent-workspace/constitution/` = 9 files, all mtime **Apr 24** (Day 1 baseline)
- → **0 proposals promoted to constitution since project start**
- `agent-workspace/memory/observations/promotion-routing-S16.md` = single planning doc; no actual promotion artifacts
- 7 lesson candidates (L-S25-1..L-S34-1) batched in `agent-notes.md` with annotation "promote at Phase 2 close per Q-E2"
- Phase 1 close (S30) did **NOT** run promote-rule subagent — implicit defer

### Drift check scope gap

- `/drift-check` skill runs DR1-DR12 from `constitution/drift-signals.md` — all technical (LOC, self-attest, charter md5, spec refs, cross-BC, LLM-math, etc.)
- `human-workspace/user_prompt/` has **8 prompts** since project start (UP-01 init, UP-02 init, UP-03..UP-08 amendments)
- Em never re-read all 8 user_prompts at phase boundary to verify intent alignment (AP-5 violation per CLAUDE.md SYNTHESIS § 6)
- Q&A pending `2026-04-29-004-up06-track-5.5-amendment.md` **stale 3+ days** without sweep

---

## Root cause analysis (LLM cognitive failure modes)

### 1. Plan-fidelity > meta-loop-fidelity
Em focused on master-plan 005 § Sessions S32/S33/S34 deliverables (BC-1 expand, BC-2 author). Continuous loops (mistake-log, KI/BP cards, promotion) were not in the master-plan deliverable matrix → invisible. The plan defines what's "in scope" for each session; meta-loops are out-of-band, hence skipped.

**Anti-pattern**: treating continuous overhead as project-bounded deliverables.

### 2. "Defer to phase close" black hole
Lessons batched with mindset "promote at S43". 9 sessions S25-S34 passed; KI/BP cards static; lessons unpromoted; gap compounds. The Q-E2 doctrine ("promote at phase boundary") sounds disciplined but in practice means "never" because phase boundaries are themselves crowded with closure work.

**Anti-pattern**: deferral without frequency cap. Should be "promote every N sessions" not "promote at phase close".

### 3. CLAUDE.md § Session End checklist incomplete
5-step ritual covers session-state updates but missing:
- "Update mistake-log if any failure / drift / user correction happened"
- "Populate self-awareness profile card for active (model, effort, task_class)"
- "Trigger promote-rule subagent if N≥10 unpromoted lessons"

Implicit-from-spec ≠ enforced-as-ritual. Without ritual, agent skips.

**Anti-pattern**: spec-not-ritual gap. Track 9 lives in spec but not in Session End checklist.

### 4. Confused one-shot deliverables with continuous loops
Track 9 (self-awareness) was built S19 as one-shot deliverable (templates + aggregator + skill). Em treat as "shipped" → forgot Track 9 = continuous obligation. Same pattern with promotion cycle.

**Anti-pattern**: ship-and-forget continuous-obligation.

### 5. Drift-check scope blind to human-intent layer
`/drift-check` runs technical signals only (DR1-DR12). Never includes "re-read user_prompt/{01..N} and check current trajectory against latest intent". CLAUDE.md SYNTHESIS § 6 AP-5 explicitly names this as anti-pattern, but `/drift-check` skill doesn't operationalize it.

**Anti-pattern**: drift-check covers code, not intent.

### 6. Subagent reports treated as final word (echo chamber)
Drift-detector subagent earlier in this session reported "PASS-WITH-RESIDUE 0 HIGH" — em accepted it. But subagent ran DR1-DR12 only (same scope gap as `/drift-check`). Did not check self-awareness loop liveness or promotion cycle. Em didn't cross-verify subagent's scope vs human-required scope.

**Anti-pattern**: agreement = validation; AP-1 (same-class self-review).

---

## Recovery plan

See `agent-workspace/session-plans/pending/006-S35-meta-loop-recovery.md`.

---

## Promotion candidates from this post-mortem

### Rule (priority 1 → hook)
- **promote-rule auto-trigger**: Stop hook detects "≥3 lesson candidates batched OR ≥10 sessions since last promotion" → fires promote-rule subagent dispatch automatically. Currently `Q-E2 doctrine "promote at phase boundary"` is loose; tighten to N-cap.
- **session-end-checklist linter**: Stop hook verifies last session log mentions mistake-log update OR explicit "no mistakes this session" — soft-warn if missing.

### Skill (priority 2)
- Extend `/drift-check` skill: append "DR-INTENT" signal — diff `human-workspace/user_prompt/*` content against active `current-execution.md` Goals section; flag soft if any UP item is not addressed.

### Charter (priority 3)
- Amend CLAUDE.md § Session End: add explicit step "If failure / drift / user-correction happened: append M-S{N}-* entry to mistake-log.md" and "If new lesson emerged: append KI-S{N}-* card to known-issues.md (not just agent-notes)".

---

## Severity & impact

- HIGH on meta-discipline (loops dead, can't see gaps without manual audit)
- LOW on production code (BC-1/BC-2 deliverables shipped clean; tests pass; cross-BC discipline now enforced post-S34 mid-session refactor)
- MEDIUM on user-trust: em emitted false drift report claiming files missing that exist → erodes confidence in em's audit capability
