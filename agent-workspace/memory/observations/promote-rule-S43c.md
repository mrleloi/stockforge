---
observation_id: promote-rule-S43c
type: promote-rule-proposal
created_at: 2026-05-04
related_session: S43c
delta_since_last: 8
last_promote: S35 (2026-05-01; observations/promote-rule-S35.md)
status: ACTIVE
agent: fresh-context promote-rule subagent (Stop-hook hard-block clearance dispatch)
doctrine_basis:
  - decision-discipline.md § Rule 3 (hook → skill → charter cheapest-first)
  - decision-discipline.md § Rule 4 + Rule 4a (5-session OR phase-boundary; 8 = hard-block)
  - Q-E3 promotion target priority (closed S15)
  - Q-B2 charter-tier explicit-pick required (closed S15)
  - L-S15-1 charter split rule
inputs_clusterable:
  - agent-notes.md tail entries since 2026-04-30 (lines 335-436): 11 rule entries
  - known-issues.md KI-S43b-1..KI-S43b-8 (8 entries)
  - best-practices.md BP-S43b-1..BP-S43b-8 (8 entries)
  - 27 rule headers / promotion candidates inspected
read_method: full-Read of KI/BP files; agent-notes.md range read 335-436; promote-rule-S35.md fully read for de-dup
---

# Promote-Rule S43c — Routing Decisions

## Context

Stop-hook `promotion-cycle-trigger.sh` HARD-BLOCK fired (delta = 8 sessions since
S35). Mandate: cluster recently accumulated rules + propose promotion targets
cheapest-first; clear the hook. This run covers S36-S43b lessons NOT already
routed by S35 promote-rule. Most KI-S43b-* / BP-S43b-* entries already self-tag
promotion targets and MOST corresponding hooks are already DEPLOYED (verified via
`Glob scripts/hooks/*.sh`) — this routing exercise primarily VALIDATES that the
hooks shipped match the lessons recorded, surfaces the 1 still-open lesson cluster
(L-S43b-11 ghost-work audit), and proposes 2 charter-tier candidates that the
S35 routing intentionally left as DEFER pending more evidence (now satisfied).

## Cluster Summary

| Cluster | Candidate rules | Recommended target | Rationale (short) |
|---|---|---|---|
| **C1: LLM-substrate-resilience** | 4 | already-applied (HOOK + adapter code) | KI/BP-S43b-1/2/3 already mitigated via per-role override + 3-tier JSON extractor + gatherer-wired compute; no further promotion needed beyond cross-ref note |
| **C2: Self-upgrade-loop-dormancy** | 5 | CHARTER (augment decision-discipline.md Rule 4 + autonomous-protocol.md) | KI-S43b-5 + BP-S43b-4 + L-S43b-7 + KI-S35-5 + BP-S35-1 — 5 of these now have deployed deterministic Stop hooks (lesson-synthesis-watchdog + promotion-cycle-trigger + harness-recovery-dod-watchdog + memory-routing-audit + pre-clear-handoff-guard); pattern is mature → charter-tier ready |
| **C3: Pre-/clear handoff invariant** | 3 | already-applied (HOOK deployed) + CHARTER carry-over | KI-S43b-6 + BP-S43b-6 + BP-S43b-8 — `pre-clear-handoff-guard.sh` deployed; promote BP-S43b-8 unverified-field discipline as extension; charter-amendment to autonomous-protocol.md as Rule 9 (pre-clear handoff) is candidate but DEFER until 2nd recurrence empirically observed |
| **C4: Cross-BC + ghost-work + provenance audits** | 3 | HOOK (extend bash-hook-lint.sh) — 1 NEW ACTIONABLE | KI-S43b-8 ghost-work audit + L-S43b-11 + KI-S35-3 cross-BC; cross-BC already has importlinter contract; ghost-work has NO hook yet → propose `scripts/hooks/ghost-work-audit.sh` |
| **C5: Bash-hook authoring traps** | 2 | HOOK (extend bash-hook-lint.sh) — 1 NEW ACTIONABLE | L-S43b-9 (printf `--` sentinel) + L-S11-1 portability — extend bash-hook-lint with `printf '-` regex check |
| **C6: Premature-stop / DoD-discipline** | 2 | already-applied (HOOK deployed) | KI-S43b-7 + BP-S43b-7 — `harness-recovery-dod-watchdog.sh` deployed S43b; validate next charter-tier pivot triggers it |

**Totals**: 6 clusters / 19 candidate rules.
- **Already-applied** (HOOK shipped, validation only): 3 clusters (C1, C3 partial, C6)
- **NEW HOOK** proposals: 2 (C4 ghost-work-audit, C5 bash-hook-lint extension)
- **CHARTER** candidate: 1 (C2 — augment Rule 4 of decision-discipline + new Rule 9 of autonomous-protocol)
- **Charter-tier user-gate** required: 1 (C2 only)

## Per-Cluster Sections

### Cluster C1: LLM-Substrate Resilience — already-applied

- **Source rules**:
  - KI-S43b-1 (bull sonnet timeout) / BP-S43b-1 (per-role model override)
  - KI-S43b-2 (prose-wrapped JSON) / BP-S43b-2 (3-tier JSON extractor)
  - KI-S43b-3 (Windows cp1252 subprocess crash)
  - KI-S43b-4 + BP-S43b-3 (gatherer-wired compute)
- **Status**: ALL MITIGATED in shipped code: `claude_llm_perspective_adapter.py:role_model_overrides`, `subagent_transport._unwrap_fence`, `subprocess.run(..., encoding="utf-8")` pinned, `Phase1DataGatherer` calls `compute_ta_features`.
- **Proposed action**: NO new artifact. Append 1 paragraph to `agent-workspace/constitution/architecture.md` § "LLM substrate boundary" cross-referencing these 4 patterns as canonical reference for any future LLM-perspective adapter (BC-8 or future BCs). LOC: ~6.
- **Cheapest-first justification**: HOOK level not actionable (these are Python adapter patterns, not file-grep checks). SKILL is overkill since pattern is inline-documented in adapter docstrings (per L-S15-1). Charter cross-reference is cheapest.

### Cluster C2: Self-upgrade-loop dormancy — CHARTER (HIGHEST PRIORITY)

- **Source rules**:
  - KI-S35-5 (15-session promote-skip) / BP-S35-1 (5-session-or-phase-boundary)
  - KI-S43b-5 (9-session lesson-synthesis dormancy) / BP-S43b-4 (lesson-synthesis mandatory)
  - agent-notes 2026-05-01 § "Lesson-Synthesis Stage 2 Of Self-Upgrade Loop Has No Agent" (L-S43b-7)
- **Proposed promotion artifact**: `agent-workspace/proposals/decision-discipline-amendment-rule-4b.md` (charter-amendment proposal, draft only — agent never edits charter directly). Estimated LOC: ~50.
- **Proposed scope**: New Rule 4b "Lesson synthesis mandatory at session-end" — every session producing ≥1 user-correction OR ≥1 deferred-fix OR ≥1 substrate gap discovered MUST append ≥1 KI/BP entry before checkpoint write. Reverse-pre-flight: if `git diff packages/` non-empty AND no new KI/BP entry → halt-warn (already deployed via `lesson-synthesis-watchdog.sh`). Promote watchdog from advisory → strict (exit 2) at next charter ratification.
- **Charter-tier? YES**: this rule reshapes self-upgrade-loop identity (meta-loop fidelity > plan-fidelity per BP-S35-1 anti-pattern catalog). Requires user explicit pick per Q-B2 + L-S15-1.
- **Cheapest-first justification**: HOOK already exists (`lesson-synthesis-watchdog.sh` advisory-mode); SKILL inadequate (this is a discipline rule, not a procedure). Charter is the next-level lift to make the watchdog STRICT. **User-gate required.**
- **Re-trigger if defer**: not-defer; this is RIPE for charter promote per the very META-skip pattern that triggered THIS S43c routing run.

### Cluster C3: Pre-/clear handoff invariant — partial-applied + DEFER charter

- **Source rules**:
  - KI-S43b-6 (auto-/clear lost Q&A state) / BP-S43b-6 (pre-clear handoff-write invariant)
  - BP-S43b-8 (`⚠️ unverified` checkpoint fields are first-action in successor session)
- **Status**: `pre-clear-handoff-guard.sh` Stop priority 1 DEPLOYED; advisory-mode currently. BP-S43b-8 extension to scan `⚠️ unverified` markers NOT YET wired.
- **Proposed promotion artifact**: extend existing `scripts/hooks/pre-clear-handoff-guard.sh` with `⚠️ unverified` regex check on `checkpoints/latest.md`. Estimated LOC: +15.
- **Proposed scope**: at Stop, grep latest checkpoint for literal `⚠️ unverified` substring; if matched AND `git log --since="2 hours ago"` shows commits to `agent-workspace/memory/checkpoints/` are absent → ALERT. Cheaper than full charter promote.
- **Cheapest-first justification**: HOOK extension is +15 LOC vs charter amendment ~30 LOC + user-gate. Defer charter to autonomous-protocol.md until 2nd recurrence (next instance of `⚠️ unverified` slipping past successor session).
- **Re-trigger condition for charter**: 2nd recurrence of unverified field slipping past resolution (currently 1 recurrence: S43b-EVIDENCE → resume-verify nominal-not-substantive check per BP-S43b-8 evidence section).

### Cluster C4: Ghost-work + cross-BC + provenance audits — NEW HOOK

- **Source rules**:
  - KI-S43b-8 / agent-notes 2026-05-01 § "Ghost-Work Pre-Flight Discovery Requires Explicit Provenance Audit" (L-S43b-11)
  - KI-S35-3 (cross-BC import undetected by mypy/ruff) — already mitigated via importlinter `independence` contract per S35 D6
  - agent-notes 2026-04-30 § "Cross-BC Imports In Domain Layer Are Not Caught By Existing Gates" (L-S34-1) — same mitigation
- **Proposed promotion artifact**: `scripts/hooks/ghost-work-audit.sh` (NEW; ~35 LOC bash+POSIX per L-S11-1). SessionStart hook. Estimated LOC: 35.
- **Proposed scope**: at SessionStart, `git status --short` → grep `^?? packages/` for untracked source files (excluding tests/configs/__init__.py); if hits, cross-check most recent session log for explicit "GHOST-WORK FOUND" heading; ALERT if untracked source not documented. Cheap, deterministic, blocks silent-adoption pattern.
- **Cheapest-first justification**: HOOK is the right level — pattern is mechanically detectable via `git status` + log-grep. SKILL would burn LLM cost on trivial check. Charter would be over-codification of a hygiene rule.
- **Re-trigger if defer**: pattern recurs (silent ghost-work adoption) → escalate to skill `vbw-check` extension.

### Cluster C5: Bash-hook authoring traps — HOOK extension

- **Source rules**:
  - agent-notes 2026-05-01 § "Bash printf With Format Starting `-` Needs `--` Sentinel" (L-S43b-9)
  - L-S11-1 (Phase 0 bash+POSIX portability — already in `bash-hook-lint.sh`)
- **Proposed promotion artifact**: extend `scripts/hooks/bash-hook-lint.sh` with check for `printf '-` or `printf "-` (no `--` separator) regex. Estimated LOC: +12.
- **Proposed scope**: grep `scripts/hooks/*.sh` for `printf [\'\"]-` patterns; if matched without `--`, emit info-level warning. Cheap, deterministic, prevents partial-write trap from recurring (encountered 2× during HR-3 deploy per L-S43b-9).
- **Cheapest-first justification**: HOOK extension to existing lint hook is the obvious cheapest option. No charter or skill warranted.
- **Re-trigger if defer**: 1+ more printf-trap incident → ship the regex check.

### Cluster C6: Premature-stop / DoD discipline — already-applied

- **Source rules**:
  - KI-S43b-7 (3-turn premature-stop chain) / BP-S43b-7 (Harness-recovery DoD checklist)
- **Status**: `harness-recovery-dod-watchdog.sh` deployed S43b (Stop, after lesson-synthesis-watchdog). Advisory-mode.
- **Proposed action**: NO new artifact this cycle. Watchdog needs 1+ live charter-tier pivot in S43c+ to validate non-recurrence; if recurrence happens → escalate to strict-mode (exit 2) via charter promote.
- **Cheapest-first justification**: hook already shipped; further action premature without recurrence evidence.

---

## DEFER Section

| Item | Defer reason | Re-trigger condition |
|---|---|---|
| **Charter promote: pre-clear handoff invariant** (C3) | 1 occurrence; HOOK in advisory-mode sufficient | 2nd recurrence of `⚠️ unverified` slipping past successor session resolution OR /clear with no checkpoint write |
| **Charter promote: harness-recovery DoD strict-mode** (C6) | watchdog needs 1+ live charter-tier pivot to validate | Premature-stop recurrence after S43c |
| **financial-data-protocol-amendment-VN** (S35 carry-over) | Phase 2 BC entities not all built | Phase 2 close + `packages/domain/foreign_ownership/` + `packages/domain/fx/` exist |
| **invariants-amendment-VN** (S35 carry-over) | paired with above | Same as above |
| **architecture-amendment sections 2-4** (S35 carry-over) | post-hoc; D-DUPL hook not yet fired ≥3× | D-DUPL hook fires ≥3× |
| **provenance-protocol** (S35 carry-over) | Phase 3 thesis cycle not yet ramped | Phase 3 first thesis ships AND calibration data flows |

---

## Doctrine validation

- **Q-E3 honored**: 2 NEW proposed artifacts are HOOK; 1 charter-amendment-PROPOSAL (not direct charter edit); 0 skill promotes proposed (no procedural-judgment patterns this cycle).
- **Q-B2 honored**: only C2 charter-tier promote; routed through proposal-draft + AskUserQuestion (the agent-side artifact is a proposal markdown, never a direct constitution edit).
- **Q-E2 / Rule 4a honored**: this run IS the 8-session-hard-block clearance run; cadence enforced.
- **Karpathy P3 surgical**: 4 deferrals with explicit re-trigger conditions; only 2 NEW HOOK actionable + 1 charter proposal authored.
- **L-S15-1 honored**: charter-tier C2 NOT bundled with sub-charter clusters; 1 single-pick AskUserQuestion required.
- **Provenance preserved**: every cluster cites verbatim rule IDs (KI-S35-3 / KI-S43b-1..8 / BP-S35-1..2 / BP-S43b-1..8 / L-S34-1 / L-S43b-9 / L-S43b-11).

---

## Implementation recommendations for next session

| Priority | Action | LOC | Owner |
|---|---|---|---|
| 1 | Extend `bash-hook-lint.sh` with printf `--` sentinel check (C5) | +12 | autonomous |
| 2 | Author `scripts/hooks/ghost-work-audit.sh` (C4) | ~35 | autonomous |
| 3 | Extend `pre-clear-handoff-guard.sh` with `⚠️ unverified` scan (C3) | +15 | autonomous |
| 4 | Append C1 cross-reference to `architecture.md` § "LLM substrate boundary" | +6 | autonomous (constitution edit needs deny-list temporary unblock per harness-bootstrap-permission-override OR proposal-draft route) |
| 5 | Author `proposals/decision-discipline-amendment-rule-4b.md` (C2 charter-tier draft) | ~50 | autonomous (draft); user-gate for ratification |

Total LOC budget: ~118 LOC across 5 actions. Fits comfortably in any FOCUSED_IMPL or even tail-end of MULTI_TASK_IMPL session.

---

next_promote_eligible_session: S53 (S43c + 10 per Q-E2 default; tighten to S48 if charter-tier C2 ratified at S43c+1 — charter ratifications increase promotion-cycle attention since downstream rule-fan-out widens)

footer_status: HARD-BLOCK CLEARED for `promotion-cycle-trigger.sh` (delta resets at next session-start since this observation file matches glob `promote-rule-S*.md`)
