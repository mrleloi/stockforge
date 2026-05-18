# Chapter 8 — Lifecycle

> **Diataxis quadrant**: Explanation + Reference
> **Reading time**: ~40 minutes
> **Prerequisites**: Chapter 3 (Architecture), Chapter 5 (Skills/Commands/Agents)

The harness's lifecycle is the *temporal structure* — how sessions flow, how plans move from authored to executed, how decisions ratify, how subagents coordinate. This chapter walks the lifecycle end-to-end.

If Chapter 6 was the mechanism (hooks) and Chapter 7 was the state (memory), this chapter is the *process* that ties them together.

---

## 8.1 — Session Types

Per [`session-budgets.md`](../../../agent-workspace/constitution/session-budgets.md), the harness recognizes 8 session types. Each has a distinct purpose, budget, and ritual.

| Type | Budget (Sonnet) | Budget (Opus) | Purpose |
|---|---|---|---|
| **PLAN** | 50-80K | 150-230K | Architect; produces session plan |
| **FOCUSED_IMPL** | 100-150K | 100-150K† | Dev; 1-3 tasks from plan |
| **MULTI_TASK_IMPL** | 150-250K | 200-330K | Dev; 4-10 tasks |
| **VERIFY** | 30-60K | 80-180K | Verifier; adversarial review |
| **RECOVERY** | 80-150K | 130-230K | Revert + re-plan after failure |
| **THESIS** | 60-100K | 100-180K | Multi-perspective stock analysis |
| **INGEST** | 40-80K | 80-150K | Process new data sources into KB |
| **POST_MORTEM** | 30-50K | 60-100K | Review thesis outcomes; update calibration |

† Dev on Opus shows under-budget actuals empirically (file-bounded work resists token inflation).

### Hard Rules

- **Never mix PLAN and IMPL in same session.** (Session 4 catastrophic failure mode.)
- **THESIS sessions are read-only on code.** Output goes to `agent-workspace/memory/thesis-log/`.
- **Per D-004 thresholds**:
  - Wind-down: 180K (auto-prep handoff)
  - Cliff: 220K (auto-reboot via `session-self-reboot.sh`)
  - Hard cap: 250K (mandatory split)

### Type-Selection Decision Tree

`/session-start` uses this tree (per [`session-budgets.md`](../../../agent-workspace/constitution/session-budgets.md)):

```
No detailed plan exists?
  → PLAN
Plan exists; 1-3 small tasks?
  → FOCUSED_IMPL
Plan exists; 4-10 tasks?
  → MULTI_TASK_IMPL
Plan exists; >10 tasks?
  → recommend split
Previous session failed/broken?
  → prepend RECOVERY
Need to verify previous session output?
  → schedule VERIFY after main work
Goal is investment thesis on a stock?
  → THESIS (read-only on code)
Goal is data ingest / KOL channels?
  → INGEST
Goal is reviewing past thesis outcomes?
  → POST_MORTEM
```

---

## 8.2 — Session Protocol

Per CLAUDE.md § Session Protocol:

### Start

1. Read `agent-workspace/memory/current-execution.md` → resolve active track
2. Read `agent-workspace/memory/project.md` → project state
3. Read last 3 files in `agent-workspace/memory/sessions/` → recent context
4. Check `agent-workspace/session-plans/pending/` for matching brief
5. Run VBW protocol before writing any spec/test/code

### End

1. Update `agent-workspace/memory/project.md` (if architectural decisions made)
2. Write `agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md`
3. Update `agent-workspace/memory/current-execution.md` (status, next session)
4. If learned rule emerged → append to `agent-workspace/memory/agent-notes.md`
5. If thesis logged this session → ensure entry in `agent-workspace/memory/thesis-log/`
6. Update `agent-workspace/memory/mistake-log.md` with new `M-S<N>-<M>` entries OR explicitly state "no mistakes this session" in the session log (enforced by `session-end-checklist-linter.sh`)
7. If a NEW ADR landed this session → verify `project.md` Phase Goals Tracker still matches `current-execution.md` Active Focus Track Phase status (enforced by `phase-status-coherence.sh` UserPromptSubmit cadence + `project-md-adr-staleness.sh` Stop cadence)
8. **(auto)** Stop-hook `profile-template-auto-populate.sh` appends a sample row to the matching `agent-workspace/memory/self-awareness/profiles/<model>-<effort>-<task_class>.md` card
9. **(auto)** Stop-hook `promotion-cycle-trigger.sh` HARD-BLOCKs at next SessionStart if ≥8 new lessons accumulated since last `promote-rule` dispatch — schedule a `promote-rule` subagent dispatch in the next session if blocked

---

## 8.3 — The Plan Lifecycle

Plans live a two-stage life: authored (pending/) → executed (completed/).

### Master Plans vs Session Plans

| Tier | Location | Scope | Lifespan |
|---|---|---|---|
| **Master plan** | `agent-workspace/master-plans/` | Phase-level (months) | Long-lived; archived per phase |
| **Session plan** | `agent-workspace/session-plans/pending/` then `completed/` | Session-level (1-3 sessions of work) | Active while in pending; archived on completion |

### Naming Convention

```
NNN-S<authoring-session>-<slug>.md
```

Example: `045-S395-vhm-thesis.md`.

Current high water mark: **046**.

### Plan Body (Authored by Architect)

A typical plan is 700-1100 LOC and follows sections A-N. Heavy YAML frontmatter:

```yaml
---
id: <NNN>
authored_at: <ISO-8601>
authoring_session: S<N>
session_type: FOCUSED_IMPL  # what type of session executes this
estimated_duration_min: 45
estimated_budget_tokens: 130000
estimated_cost_usd: 1.50
target_substrate: code | data | both
depends_on:
  - plan-NNN: file:line citation
  - D-NNN: ADR title
binding_decisions:
  - <decision>
hard_rules_acknowledged:
  - <CLAUDE.md rule>
  - <constitution rule>
parallel_with: [D2, D3]  # if sub-tracks can parallelize
---
```

### Body Sections (Canonical A-N Structure)

```markdown
## A — Scope
[what this plan accomplishes]

## B — Out-of-Scope
[explicit non-goals; what's deferred to other plans]

## C — VBW STEP 0 (Live Verification)
[verifications the dev must perform before writing any code]

## D — Sub-Tracks (D1, D2, D3, ...)
[each sub-track with: goal, files, success criteria, LOC ceiling]

## E — Architecture Decisions
[any ADRs this plan proposes]

## F — File Scope
[exhaustive list of files to create/modify with size estimates]

## G — Coordination Rules
[parallel-eligible flags; file-collision avoidance]

## H — DoD (Definition of Done) Per Sub-Track
[per-D# acceptance criteria; per-category LOC ceilings]

## I — Risk Mitigations (RM1..RMN)
[named risks + mitigation plans]

## J — Cost Attestation
[budget vs cap reconciliation]

## K — Stop-Findings
[any unresolved issues that block; STOP-AND-ASK gates]

## L — Companion Artifacts
[firing-tests, observations, ADRs to be written]

## M — Compliance Attestation
[hard rules respected]

## N — Out-of-Plan Items
[bookkeeping notes carried forward]
```

### State Transitions

```
authored (in pending/)
  ↓ session starts to execute
in-progress (dev session active)
  ↓ dev session completes
attesting (verifier session active)
  ↓ verifier returns PASS or PASS-WITH-CONCERNS
shipped (completed/) ← mv from pending/ to completed/
  ↓ if FAIL
remediation-needed (still in pending/; defects logged)
  ↓ defects fixed
re-attesting → ... → shipped
```

The `mv` from `pending/` to `completed/` is the **canonical "done" signal**. Hooks consume this signal:
- `harness-recovery-dod-watchdog.sh` checks for plans stuck in pending/ longer than 5 sessions
- `sub-plan-completion-coherence.sh` checks consistency between plan status and `current-execution.md` claim

---

## 8.4 — The Sandwich Pattern (Choreography)

The sandwich pattern — architect → dev → verifier — is the canonical workflow. Detailed mechanics are in [Chapter 5 § Sandwich Architect Mechanics](05-skills-commands-agents.md#sandwich-architect-mechanics); here is the choreography across sessions.

### Phase 1: Architect (PLAN session)

```
USER: /master-plan <feature>
  ↓
main session dispatches master-planner subagent
  ↓ (fresh context)
master-planner reads:
  - PROJECT_CHARTER.md
  - current-execution.md (active phase)
  - relevant constitution files
  - existing plans in pending/ and completed/
master-planner returns:
  - session-plans/pending/NNN-*.md (the master plan)
  - one observation file (dispatch artifact)
  ↓
main session reads observation, persists outcome
  ↓
USER: /session-end → SessionEnd hooks fire
  ↓
NEXT SESSION: /session-start
  ↓ /session-start reads pending/NNN-*.md → detects PLAN required for sub-tracks
  ↓
main session dispatches sandwich-architect subagent
  ↓ (fresh context, Opus 150-230K)
architect reads:
  - master plan
  - relevant code in affected BCs
  - calibration data (Phase 1b self-calibration if ≥3 sub-tracks)
architect produces:
  - sub-plan (D1..DN tasks)
  - dispatch artifact
```

### Phase 2: Dev (FOCUSED_IMPL or MULTI_TASK_IMPL session)

```
NEXT SESSION: /session-start
  ↓ reads sub-plan from pending/
  ↓ detects FOCUSED_IMPL or MULTI_TASK_IMPL type
main session dispatches sandwich-dev subagent
  ↓ (fresh context, Opus 100-330K)
dev reads:
  - sub-plan
  - relevant code (per File Scope section)
dev executes STEP 0 VBW re-verification
dev implements D1..DN per plan
dev runs:
  - mypy --strict
  - pytest
  - ruff
  - bash-hook-lint (if hooks touched)
dev writes:
  - session log with verification block
  - any new ADRs to decisions/NNN-*.md
  - mistake-log entry OR M-S<N>-NONE attestation
dev's session ends; plan stays in pending/
```

### Phase 3: Verifier (VERIFY session)

```
NEXT SESSION: /session-start
  ↓ detects pending VERIFY for the prior IMPL session
main session dispatches sandwich-verifier subagent
  ↓ (fresh context, Opus 80-180K)
  ↓ NO Write tool grant (per PCG-S401-4)
verifier reads:
  - sub-plan
  - dev session log
  - all files touched per File Scope
  - relevant tests
verifier runs V1..V12 verification grid:
  - V1 acceptance criteria check
  - V2 dev handoff notes check
  - V3 charter compliance
  - V4 architecture compliance
  - V5 regression (firing-tests + pytest + mypy/ruff re-run)
  - V6 integration smoke
  - V7..V12 per-plan-specific
verifier returns inline text:
  - verdict (PASS / PASS-WITH-CONCERNS / FAIL)
  - CRITICAL / IMPORTANT / MINOR finding counts
  - promotion candidates
main session persists verifier's findings to:
  - attestation-log.tsv (one row)
  - observation file (under main's authorship per PCG-S401-4)
main session decides:
  - PASS → mv plan-NNN from pending/ to completed/
  - PASS-WITH-CONCERNS → mv if merge-eligible; log defects
  - FAIL → leave in pending/; dispatch new dev session with remediation
```

### Why Three Fresh Contexts

- **Architect's context** is filled with: spec, constitution, calibration data, code.
- **Dev's context** is filled with: plan, code-to-touch, test runner.
- **Verifier's context** is filled with: plan, diff, test results.

Each is **scoped to its job**. Combined, they hold ~400-700K tokens of relevant material — far more than any single session could carry. And because each is fresh-context, none can rationalize the other's mistakes.

### The Coordination Problem

When parallel sandwich sessions run (e.g., two dev sessions on independent sub-plans), the **Coordination Rules** section of `current-execution.md` lists file-collision avoidance:

```markdown
**Coordination rule (S315 active)**: main session avoids
`scripts/hooks/python-determinism-check.sh`,
firing-test,
`decisions/059-*`,
`.claude/settings.json` (W0-2 wire-up section),
`sessions/session-315.md`.
```

Hooks (`destructive-command-guard.sh`, `write-vs-edit-guard.sh`) enforce some of these; coordination rules are the soft layer of explicit avoidance.

---

## 8.5 — Decision Discipline in Practice

ADRs are authored as part of plans. The lifecycle:

### State Transitions

```
PROPOSED (author writes ADR; status PROPOSED)
  ↓ cool-down per tier
  ↓ CHARTER: 48h
  ↓ SCOPE: 24h
  ↓ ARCH: 12h
  ↓ IMPL: 0h (auto)
  ↓
ACCEPTED (user ratifies via AskUserQuestion OR auto for IMPL tier)
  ↓ implementation lands
  ↓
SHIPPED (companion code/hook/file landed; verified)
  ↓ if later superseded
  ↓
SUPERSEDED-BY-D-NNN (status changes; never deleted)
```

### Per-Tier Decision Path

| Tier | Confidence threshold | Decision path | Cool-down |
|---|---|---|---|
| **CHARTER** | 0.99 | Always AskUserQuestion bundle + human ratify | 48h |
| **SCOPE** | 0.90 | AskUserQuestion if <0.90 | 24h |
| **ARCH** | 0.80 | Self-decide if ≥0.80 | 12h |
| **IMPL** | 0.50 | Self-decide if ≥0.50 | 0h |

### Approval Chain Field

```yaml
approval_chain:
  - source: sync-tracker/state.tsv (Confidence Score: 0.92)
  - source: human-workspace/user_prompt/<file>.txt § directive
  - source: master-plan / phase entry
  - source: AskUserQuestion <bundle-id> Q1=A
```

### Pre-Dispatch ADR Number Check

`pre-dispatch-adr-number-check.sh` (PreToolUse) prevents ADR number collision when multiple subagents try to author ADRs in parallel sessions. Reads `decisions/` directory listing; if dispatched architect's brief cites a number already in use, hook flags it.

---

## 8.6 — Workspace Dualism

The agent's domain is `agent-workspace/`. The human's domain is `human-workspace/`. They communicate through explicit channels.

### Channels

| Direction | Channel | Purpose |
|---|---|---|
| Human → Agent | `human-workspace/user_prompt/<file>.txt` | New prompts that may reshape scope |
| Human → Agent | `human-workspace/decisions/<file>.md` | Formal ratifications |
| Agent → Human | `human-workspace/q-and-a/pending/<bundle>.md` | Questions awaiting answer |
| Bidirectional | `human-workspace/q-and-a/answered/<bundle>.md` | Resolved Q&A (auto-mv from pending/) |
| Agent → Human | `human-workspace/notifications/urgent.md` | Severity escalations |

### Permission Boundaries

| Channel | Agent can | Hooks enforce |
|---|---|---|
| `user_prompt/` | Read only | `Write/Edit(user_prompt/**)` denied in settings.json |
| `decisions/` | Read only | `Write/Edit(decisions/**)` denied |
| `q-and-a/pending/` | Write + Edit | Per agent-workspace/CLAUDE.md auto-mv rule |
| `q-and-a/answered/` | Auto-mv only via hook | `Write/Edit(answered/**)` denied to agent direct |
| `q-and-a/stale/` | Auto-mv only via hook | `Write/Edit(stale/**)` denied |
| `notifications/urgent.md` | Append (via Edit) | Permitted explicitly |

### The Auto-Mv Rule (HH-E.2 / D-031 — 2026-05-05 ratified)

Agent MAY mv a bundle from `q-and-a/pending/` to `q-and-a/answered/` IFF **ALL** of the following hold:

1. **Frontmatter signal**: bundle frontmatter `status:` field value starts with one of: `answered-`, `closed-`, `resolved-`. Examples already in repo: `answered-via-chat`, `answered-via-AskUserQuestion`, `answered-2026-05-04-via-chat`. Detection is deterministic (head -20 of file + grep `^status:`).
2. **No human-veto signal**: bundle frontmatter has NO `wait_until:` ISO-8601 timestamp greater than current epoch. If present, agent MUST defer mv until that timestamp passes. Allows human to override auto-mv per-bundle without contract amendment.
3. **No global pause**: file `human-workspace/q-and-a/.auto-mv-paused` does NOT exist. Single empty file presence pauses ALL auto-mv (global kill switch).
4. **Hook validation**: the mv is performed by `scripts/hooks/qa-pending-auto-mover.sh` (Stop hook). Direct manual `mv` invocation by agent (e.g., via Bash tool) is STILL forbidden — only the validated hook path is authorized.

### Stale Q&A Lifecycle

`qa-pending-stale-mover.sh` (SessionStart) moves Q&A bundles past `wait_until:` to `stale/`.

`qa-stale-urgent-escalator.sh` (Stop) escalates >48h pending to URGENT (HIGH severity in pipeline).

---

## 8.7 — The Q&A Bundle Mega-Pattern

When the agent needs human input, it bundles questions per `grill-maximization` skill.

### Why Bundle

Single-question prompts thrash the human's context. Bundling:
- Reduces round-trips
- Surfaces decision dependencies (Q3 depends on Q1's answer)
- Forces agent to commit to a state of pending questions

### Bundle Anatomy

```markdown
---
bundle_id: <YYYY-MM-DD-NNN>
authored_at: <ISO-8601>
authoring_session: S<N>
status: pending | answered-<source>-<date> | closed | stale
wait_until: <ISO-8601, optional>
intent_classification: SCOPE | CHARTER | ARCH | IMPL
priority: critical | high | medium | low
askuserquestion_fired: false | true (set when AskUserQuestion called)
---

# Q&A Bundle <id> — <topic>

## Context
[what prompted this bundle]

## Q1 — <short title> (<CHARTER | SCOPE | ARCH | IMPL>)
**Decision needed**: <one sentence>
**Options**:
- (A) <option> — recommended, because <rationale>
- (B) <option> — fallback, because <rationale>
- (C) <option> — defer, because <rationale>
**Agent's lean**: A (confidence 0.75)
**Why this matters now**: <consequence of delay>

## Q2 — ...
[similar]

## Q3 — ...
[similar; can be up to ~20 questions in mega-bundle]
```

### `AskUserQuestion` Binding Surface

The actual binding decision happens via the `AskUserQuestion` tool, which displays a UI prompt:
- Max 4 questions per call
- Each question has 2-4 options (5th "Other" auto-added)
- User picks per question

**Bundling logic**: if bundle has >4 questions, agent picks the highest-priority 4 for the first `AskUserQuestion` call; remaining questions wait for follow-up calls.

### Mega-Bundle Rule

Per `qa_bundle_all_pending` user memory: bundle ALL pending Q&A across topics into ONE mega-bundle; never piecemeal. Every Q must have lettered options.

---

## 8.8 — Continuity Across `/clear` and Auto-Reboot

The harness preserves continuity across two boundaries:
- `/clear` — user manually resets the session
- Auto-reboot — `session-self-reboot.sh` triggers at cliff (220K) or wind-down (180K)

### Checkpoint Mechanism (3-Hook Choreography)

```
[during session]
  ↓ Edit/Write to checkpoints/latest.md
checkpoint-write-marker.sh (PostToolUse)
  ↓ writes .checkpoint-written-<sid>
  ↓ if autonomous_mode=true: also writes .fresh-resume-pending-<sid>
  ↓
[LLM tries to do anything else]
checkpoint-write-end-turn-watchdog.sh (PreToolUse)
  ↓ marker present → DENY tool call (RC=2)
  ↓ stderr: "checkpoint written; end turn"
  ↓
[user types /clear or auto-reboot fires]
  ↓ new session begins
  ↓ SessionStart fires
checkpoint-marker-cleanup-resume.sh (SessionStart)
  ↓ clears .checkpoint-written-<sid>
  ↓ reads checkpoints/latest.md "Next Action"
  ↓ surfaces next_action to LLM via system-reminder
  ↓ LLM resumes from documented next step
```

The three hooks form a continuity machine. Remove any one and the M-S49b-2 duplicate-dispatch class re-opens.

### Auto-Reboot Modes

`autonomous-stop-watchdog.sh` detects four modes:

| Mode | Trigger | Handoff |
|---|---|---|
| **A** | Stop without checkpoint, no budget alert | `continue-injector` resumes mid-session |
| **B** | Stop with budget cliff reached | `session-self-reboot.sh` for fresh-context resume |
| **C** | Premature wind-down (before cliff) | Handoff prep; resume via continue-injector |
| **D** | Clean handoff (checkpoint mtime ≤60s) | Resume reads `checkpoints/latest.md` |

**D-003 § 5.5c.5 REV-4** documents the matching `failure_mode` 8-code expansion (`B|C|D|E|H|R|T|null`) in JSONL telemetry.

### Mode-D vs SendKeys

Mode-D originally used Windows SendKeys to inject `continue` into a new session. This was revoked (per user memory `autonomous_continue_no_self_pause.md`) in favor of the checkpoint marker mechanism.

---

## 8.9 — A Real Session, Annotated

Below is an excerpt from a real session log (S407 — plan-044 G.4 IMPL):

```markdown
---
session: 407
type: FOCUSED_IMPL
model: claude-opus-4-7
plan: agent-workspace/session-plans/pending/044-S395-vhm-thesis.md
---

# Session 407 — 2026-05-19 — FOCUSED_IMPL

## Goal
Implement plan-044 G.4 — VHM PDF dogfood + BC-2 SqliteFundamentalRepository integration.

## What Happened
sandwich-dev background dispatch (agentId a82bab00b64f2dade, ~38min Opus,
3.2M tokens, 1 commit 28984c3).

D1-D6 all SHIPPED per dev self-report:
- D1: VHM 2024 PDF download via wget (10.5MB; HOSE-listed)
- D2: PDF→text extraction via pdfplumber
- D3: Claude vision adapter consumed PDF input
- D4: BC-2 SqliteFundamentalRepository persist
- D5: 12 fundamental statements persisted (VHM 2020-2024)
- D6: VHM thesis re-run; cost $4.71 (under $6 cap)

Verification:
- mypy --strict: PASS
- pytest: 1180/1 PASS (baseline 1178+2; +2 G.4 tests)
- ruff: CLEAN

## Files Touched
- packages/infrastructure/fundamental/vhm_pdf_dogfood.py — NEW (108 LOC)
- packages/infrastructure/fundamental/sqlite_fundamental_repository.py — +24 LOC
- tests/infrastructure/fundamental/test_vhm_pdf_dogfood.py — NEW (52 LOC)
- agent-workspace/memory/decisions/083-*.md — NEW ADR D-083 PROPOSED

## Decisions Made
- D-083 PROPOSED — BC-2 PDF→Fundamental shape contract; auto-accepted at IMPL tier

## Mistakes This Session
- M-S407-NONE (no mistakes; clean session)

## Verification (re-run by main)
- mypy --strict: PASS (1178+2 = 1180 cells)
- pytest: 1180/1 PASS
- ruff: CLEAN
- bash-hook-lint: CLEAN
- companion firing-tests: 7/7 PASS for new hook (atomic-write-check)

## Carry-Forward
- Verifier dispatch (S408) needed to attest D1-D6
- D-083 PROPOSED → flip to ACCEPTED on verifier PASS

## Handoff
checkpoints/latest.md written. Next action: dispatch sandwich-verifier S408
for plan-044 G.4 attestation.
```

This is the canonical session log shape. Every section is enforced by a hook or required by the session-end checklist.

---

## 8.10 — Phase Lifecycle (Macro)

Beyond sessions and plans, the harness organizes work into **Phases** (long-running, multi-month).

### Phase Goals Tracker (in project.md)

```markdown
| Phase | Target | Status | Started | Completed |
|---|---|---|---|---|
| 0 — Harness Bootstrap | ... | DONE | 2026-04-29 | 2026-04-30 |
| 1 — Foundation VHM | ... | DONE | 2026-04-30 | 2026-04-30 |
| 2 — Foundation Tier 1+2 | ... | DONE | 2026-04-30 | 2026-05-04 |
| 2.5 — Harness Hardening | ... | DONE | 2026-05-05 | 2026-05-07 |
| 3 — Tier 3+4 KOL + outer-loop | ... | PAUSED | 2026-05-05 | - |
| 3.5 — Harness Deepening | ... | DONE | 2026-05-05 | 2026-05-12 |
| 4 — Multi-perspective | ... | IN PROGRESS | 2026-05-12 | - |
| 5 — Compounding | ... | NOT STARTED | - | - |
```

### Phase Entry Ritual

When entering a new phase:
1. Author master plan (via `/master-plan` → `master-planner` subagent)
2. Update `current-execution.md` Active Focus + Phase Goals Tracker
3. Trigger `intent-vs-impl-diff` to verify no silent absorption from previous phase
4. AskUserQuestion if any SCOPE-tier sub-decisions surface

### Phase Close Ritual

When closing a phase:
1. Update `project.md` Phase Goals Tracker (Status: DONE, Completed: date)
2. Archive Active Focus narrative to phase-close observation
3. Trigger `promote-rule` to consolidate accumulated agent-notes
4. Run `harness-health-self-scan.sh` for state attestation

`phase-status-coherence.sh` continuously checks that `project.md` matches `current-execution.md`. Drift escalates to MEDIUM.

---

## 8.11 — Lifecycle Anti-Patterns

| Anti-pattern | What goes wrong | Fix |
|---|---|---|
| Mix PLAN and IMPL in same session | Session 4 failure mode | Hard rule; never |
| Single-agent self-review (echo chamber) | Verifier rationalizes architect | Separate agent for Tier 2 gate |
| Skip checkpoint write before /clear | Lost continuity (M-S49b-2) | checkpoint-write-end-turn-watchdog.sh enforces |
| Plan stays in pending/ post-verify | Stuck-plan drift | `harness-recovery-dod-watchdog.sh` flags |
| Update current-execution.md only at end | Pre-staged work drift (AP-8) | Update on task complete |
| ROUTINE-IDLE close ritual when no signal | Busy-work loop (L-S310-1) | Demote ritual; one-line state ack |
| Authored "DONE" plan when data pending | Misleading state (L-S385-2) | Use CODE-DONE-DATA-PENDING vocabulary |
| ADR PROPOSED with cool-down not honored | Charter-tier rush | `proposal-bundle-advisor.sh` enforces |
| Q&A bundle pending >24h with no action | Silent default | `qa-stale-urgent-escalator.sh` escalates |

---

## 8.12 — Where to Read Next

- **The quality gates** that lifecycle events trigger → [Chapter 9 — Quality System](09-quality-system.md)
- **How learned rules emerge from sessions** → [Chapter 10 — Self-Improvement](10-self-improvement.md)
- **How to run a sandwich cycle** → [Chapter 11 § Run a Sandwich Cycle](11-cookbook.md#run-a-sandwich-cycle)
- **Common lifecycle pitfalls** → [Chapter 12 — Internals § Anti-Patterns](12-internals.md#anti-patterns)
