---
plan_id: 006
session_target: S35
type: META_LOOP_RECOVERY
budget: ~150-200K (FOCUSED_IMPL envelope)
created: 2026-05-01
predecessor: S34 (BC-2 Fundamental DONE)
successor: S36 (Track D BC-5 News — original master-plan 005 next)
status: pending
source: human user audit 2026-05-01 + post-mortem 2026-05-01-self-awareness-promotion-skip.md
---

# S35 — Meta-Loop Recovery

> **Inserted between S34 (Track C close) and S36 (Track D start)** because user audit surfaced 15 sessions of skipped self-awareness + promotion + intent-alignment loops. Master-plan 005 § S36 onwards continues unchanged after S35 closes.

---

## Goal

Recover the 4 dead continuous loops:
1. **mistake-log loop** — backfill M-S20..M-S34 entries
2. **self-awareness KI/BP loop** — populate cards from L-S25-1..L-S34-1 + new ones from this audit
3. **promotion cycle** — run promote-rule subagent on 9 proposals + 7 lesson candidates
4. **intent-alignment drift** — extend drift-check to include `human-workspace/user_prompt/*` re-read

Plus 2 housekeeping items:
5. **harness debug** — investigate why `.cliff-fired` once-only marker blocks re-fire even after partial reboot
6. **Q&A sweep** — process pending UP06 amendment bundle (3+ days stale)

---

## Pre-flight reads (≤6)

1. `agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md` (this audit)
2. `agent-workspace/memory/agent-notes.md` (lesson candidates list)
3. `agent-workspace/proposals/` (9 proposals)
4. `human-workspace/user_prompt/*` (8 user requirements files)
5. `agent-workspace/memory/checkpoints/latest.md` (S35 entry checkpoint — written at end of S34-extension)
6. `agent-workspace/memory/self-awareness/{known-issues,best-practices,profile-template}.md`

---

## Deliverables (8 categorical)

### D1. mistake-log backfill (M-S20..M-S34)

For each session S20-S34, scan its session log + checkpoint for failure/drift/correction signals; write 1 entry. Expected ~10-15 entries (some sessions may have 0 mistakes). Plus M-S35-1 NEW from today's confabulation drift report.

Format: existing template at top of `mistake-log.md` (M-S{N}-{seq}: title / Context / Root cause / Prevention rule / Severity).

### D2. KI / BP card population

Synthesize candidate L-S25-1..L-S34-1 + L-S35-1 (NEW from today) into:
- ≥5 NEW `KI-S{N}-*` cards in `known-issues.md` (concrete reproducer + workaround + fix-target)
- ≥3 NEW `BP-S{N}-*` cards in `best-practices.md` (validated success patterns from S20-S34)

### D3. Profile cards

For each (model, effort, task_class) tuple actually exercised S20-S34, populate 1 profile card from `profile-template.md`. Expected tuples:
- Opus 4.7 / max effort / MULTI_TASK_IMPL (S33, S34)
- Opus 4.7 / max / FOCUSED_IMPL (S32)
- Opus 4.7 / max / PLAN (S31)
- Opus 4.7 / max / VERIFY (S29)
- Sonnet / default / subagent dispatch (multiple)

≥4 cards.

### D4. Promotion cycle execution

Dispatch `promote-rule` subagent (or run inline if cheap) on:
- 9 proposals in `agent-workspace/proposals/`
- 7 lesson candidates L-S25-1..L-S34-1
- Output: per-item ROUTING decision (promote-to-hook / promote-to-skill / promote-to-charter / defer / reject), with rationale.
- Apply: for items routed to "promote-to-hook" or "skill" — actually do the move/edit. For "charter" — write `D-NNN-promote-X.md` ADR + open CHARTER-tier AskUserQuestion.

Expected outcome: ≥2 proposals promoted (likely promotion candidates: provenance-protocol, autonomous-protocol both have practical use already); ≥3 lessons → hook (e.g., L-S34-1 → importlinter independence contract).

### D5. drift-check extension

Add NEW signal to `agent-workspace/constitution/drift-signals.md`: **DR-INTENT** — diff `human-workspace/user_prompt/*` against `agent-workspace/memory/current-execution.md` § Active Focus Track + Goals. Flag soft if any UP item not addressed in current trajectory.

Update `.claude/commands/drift-check.md` skill to invoke DR-INTENT alongside DR1-DR12.

### D6. importlinter independence contract (L-S34-1 promotion)

Add `[[tool.importlinter.contracts]]` of `type = "independence"` to `pyproject.toml` covering `packages.domain.market_data`, `packages.domain.fundamental`, `packages.domain.news`, `packages.domain.crowd`, `packages.domain.influence`, `packages.domain.macro`, `packages.domain.portfolio`, `packages.domain.company_intelligence`, `packages.domain.analysis` (9 BCs). Run `python -m lint_imports` to verify; if installed run as gate; if not, document install path.

This is gate-blocking before S36 ships BC-5 News (which will depend on cross-BC discipline being enforced).

### D7. Cliff marker reset + harness debug

Investigate `.cliff-fired` once-only marker: why doesn't it auto-clear after successful reboot? Add to `budget-watchdog.sh` a stale-marker-detect (>1 hour old + new session_id different from when fired → clear). Test by clearing manually and verifying re-fire.

### D8. Q&A sweep

Read `human-workspace/q-and-a/pending/2026-04-29-004-up06-track-5.5-amendment.md`; either:
- Move to `answered/` if user already addressed in-band (likely — UP-06 addressed S15)
- Re-fire AskUserQuestion if genuinely open
- Mark stale + close

Plus run `qa-pending-stale-mover.sh` manually if hook not auto-firing.

---

## Success criteria

- [ ] `mistake-log.md` has ≥10 NEW entries (M-S20..M-S35)
- [ ] `known-issues.md` has ≥5 NEW KI cards
- [ ] `best-practices.md` has ≥3 NEW BP cards
- [ ] ≥4 profile cards populated
- [ ] promote-rule cycle output: ≥2 proposals promoted + ≥3 lessons routed to hook/skill (with deliverables on disk for each promotion)
- [ ] `drift-signals.md` has DR-INTENT signal documented
- [ ] `pyproject.toml` has importlinter independence contract for 9 BCs
- [ ] `.cliff-fired` debug logic added to `budget-watchdog.sh` (or documented as deferred with reason)
- [ ] Q&A pending bundle resolved
- [ ] All 4 dead loops have process for staying alive (ritual added to CLAUDE.md OR auto-hook fired)

---

## Anti-patterns to avoid (this session)

- AP-1 (same-agent review): use fresh-context promote-rule subagent for D4, not inline self-review
- AP-2 (self-track over real-transcript): em đã >269K hard_cap. **Force fresh session via /clear after writing checkpoint**, not just continue.
- AP-5 (silent USER-CRITICAL deferral): D5 + D8 are user-CRITICAL items surfaced today; do not defer to S36+
- AP-7 (performative SC ticking): if D4 promote-rule reveals proposals are obsolete, mark "rejected with reason" rather than fake-promote
- AP-23 (continuous LLM Guardian): D5 must result in deterministic hook OR added to existing /drift-check skill, not in continuous prompt-injection

---

## Estimated decomposition

| Step | Type | Tool | Budget |
|---|---|---|---|
| D1 mistake-log backfill | deterministic-ish (read session logs, write entries) | main session | ~30K |
| D2 KI/BP cards | synthesis + write | main session | ~20K |
| D3 profile cards | synthesis | main session | ~15K |
| D4 promotion cycle | LLM judgment + Edit | promote-rule subagent fresh ctx (~80K dispatch) + main apply (~30K) | ~110K |
| D5 DR-INTENT signal | deterministic Edit (drift-signals.md + skill) | main | ~10K |
| D6 importlinter contract | deterministic Edit (pyproject.toml) | main | ~5K |
| D7 cliff marker debug | bash logic + test | main | ~10K |
| D8 Q&A sweep | Read + move | main | ~5K |
| Lifecycle | session log + checkpoint + current-execution update | main | ~10K |
| **Total** | | | **~215K** within FOCUSED_IMPL 100-150K budget WITH subagent dispatch absorbing peak |

If main session approaches 150K → split: D1+D2+D3 (~65K) in part A; D4+D5+D6 (~125K) in part B; D7+D8+lifecycle (~25K) tail.

---

## Successor plan

After S35 closes:
- S36 = Track D BC-5 News (per master-plan 005, unchanged)
- All subsequent meta-loops will run continuously per new ritual:
  - Every session-end: update mistake-log if applicable
  - Every 10 sessions OR phase boundary (whichever first): run promote-rule subagent
  - Every phase entry: re-read all `human-workspace/user_prompt/*` (DR-INTENT)
