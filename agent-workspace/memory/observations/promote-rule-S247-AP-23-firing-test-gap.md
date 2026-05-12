---
observation_id: promote-rule-S247-AP-23-firing-test-gap
type: promotion-proposal
created_at: 2026-05-11T~20:30+07:00
session: S247
skill: promote-rule
focus_class: AP-23 "harness-firing-test-gap" (Windows-spawn-context defects)
instance_count: 6 (threshold OVERDUE; AP-23 fires at >=3)
priority_target: HOOK (Q-E3 priority 1)
status: PROPOSAL — not auto-implemented this turn
---

# Promotion Proposal — AP-23 "harness-firing-test-gap" class (6 instances)

## Cluster identification

Single tight cluster, lexically + causally homogeneous: **every instance is a harness hook that shipped with a GREEN companion firing-test, then revealed a defect at production fire because the firing-test fixture invoked the hook via direct bash and did NOT exercise Claude Code's actual Windows hook-executor spawn topology (env-var export, $PPID parentage, command-string parsing).**

### Source instances (with citation + as-of date)

| # | Instance | Defect | Source | As-of |
|---|---|---|---|---|
| 1 | M-S189-1 | HH-H.1 300s idle threshold designed for fast turns; real turn lengths >300s | `agent-workspace/memory/agent-notes.md:54` | 2026-05-08 |
| 2 | S243 lock-trap | `single-claude-instance-lock.sh:30` `trap 'rm -f "$LOCK"' EXIT` removed lock microseconds after creation | `agent-workspace/memory/observations/sandwich-dev-S244-lock-trap-fix.md:21-26` | 2026-05-10 |
| 3 | S245 lock-pid-secondary | `CLAUDE_PID` not exported + `$PPID=1` in spawned hook → `tasklist //FI "PID eq 1"` never matches `claude.exe` | `agent-workspace/memory/observations/2026-05-10-S245-lock-pid-secondary-defect.md:14-43` | 2026-05-10 |
| 4 | S245 env-prefix Form-A | bare `VAR=val bash "..."` → `bash: VAR: No such file or directory` under Claude Code Windows wrapper | `agent-workspace/memory/agent-notes.md:35-40` + `2026-05-11-S247-env-prefix-positional-fix.md:28` | 2026-05-10 |
| 5 | S245 grep-multi-match | `grep -oE 'S[0-9]+'` returned multiple matches across file; needed `head -1` to disambiguate | `agent-workspace/memory/agent-notes.md:35-40` | 2026-05-10 |
| 6 | S247 env-prefix Form-B | `env VAR=val bash "..."` → `/usr/bin/env: cannot execute binary file` (PE32+ binary on Windows + double-env wrap) | `agent-workspace/memory/observations/2026-05-11-S247-env-prefix-positional-fix.md:9-32` + `checkpoints/latest.md:14-22` | 2026-05-11 |

Existing partial guard: `scripts/hooks/settings-inline-env-prefix-detector.sh` (L-S208-1) catches Form-A (`"command": "VAR=val ...`) but its regex `"command":[[:space:]]*"[A-Z_][A-Z_0-9]*=` does NOT match Form-B (`"command": "env VAR=val ...`). Confirmed by reading the script (lines 28-32, as of 2026-05-11). 6th instance shipped past it.

## Q-E3 priority chosen: **HOOK (priority 1)**

Rationale: every failure mode in this class is **statically detectable via regex on `.claude/settings.json` + structural lint on companion firing-test fixtures**. No judgment required — these are pattern matches against known-bad command shapes and known-missing test scaffolding. Burning skill budget or charter revision here violates AP-23 (the meta-anti-pattern: LLM-Guardian creep when bash can guard).

## Proposed deterministic hook

### Rule text (1 sentence)

> Any hook command in `.claude/settings.json` that uses non-default arg-passing (inline-env-prefix Form-A `VAR=val cmd`, env-wrap Form-B `env VAR=val cmd`, `bash -c '...'`, or stdin redirect `<<<`) MUST have a companion firing-test that invokes the hook via the SAME shape it will receive from Claude Code's Windows hook executor — NOT direct bash invocation in dev-shell context.

### Hook script

- **Path**: `scripts/hooks/firing-test-spawn-context-lint.sh`
- **Trigger event**: `Stop` (cheapest; runs once per turn end, like sibling `settings-inline-env-prefix-detector.sh`)
- **Severity**: WARN-only (exit 0; append to `.session-hooks.log`) — matches Phase 3.5 hook style; PROMOTE TO BLOCKING after 5 sessions of clean state per S99 ritual-demotion doctrine
- **Companion firing-test**: `scripts/hooks/firing-tests/firing-test-spawn-context-lint-fire-test.sh`

### What it checks (3 deterministic passes)

1. **Pass 1 — Form-B env-wrap detection** (NEW, the Form-B gap from S247):
   Regex on `.claude/settings.json`: `"command":[[:space:]]*"env[[:space:]]+[A-Z_][A-Z_0-9]*=`. FAIL if any match. (Companion to existing Form-A detector; closes the form-ping-pong.)

2. **Pass 2 — Non-default arg-passing inventory**:
   For each hook command in `settings.json`, classify command shape: `default` (`bash "<path>"`) | `positional-arg` (`bash "<path>" <arg>`) | `inline-env-A` | `env-wrap-B` | `bash-c` | `stdin-redirect`. For every non-default shape, require existence of `scripts/hooks/firing-tests/<basename>-fire-test.sh`. FAIL if missing OR if firing-test source contains no `# SPAWN-CONTEXT:` marker comment (see Pass 3).

3. **Pass 3 — Spawn-context simulation marker**:
   For every firing-test fixture in `scripts/hooks/firing-tests/`, if the corresponding hook in `settings.json` uses non-default arg-passing, the firing-test source MUST contain a marker block:
   ```
   # SPAWN-CONTEXT: <form>
   # Reproduces Claude-Code Windows spawn topology:
   #   - CLAUDE_PID unset (or PPID=1 simulation via env -i + setsid)
   #   - command invoked exactly as Claude Code would: <verbatim shape>
   ```
   FAIL if marker absent. This forces firing-test authors to mentally model the actual production spawn — the root cause of all 6 instances was authors mentally modeling dev-shell invocation instead.

### FAIL condition (composite)

`Pass1.violations > 0 OR Pass2.missing_or_unmarked > 0 OR Pass3.unmarked > 0` → emit WARN line per violation to `.session-hooks.log` with shape `[TS] firing-test-spawn-context-lint: state=WARN class=AP-23 hook=<name> form=<shape> reason=<form-B|no-firing-test|no-spawn-marker>`. After 5 sessions clean, agent promotes hook to exit-2 BLOCKING (per S99 ritual-demotion mirror: ritual-promotion when catch-rate stable).

### Capability-map touch

- `task_class`: `harness-defect-detection` (existing) — append row `harness-firing-test-gap | hook | regex+structural lint | deterministic | confidence=high`

### Confidence

**HIGH**. All 6 instances are pattern-detectable. Form-B regex is a 1-line addition; spawn-context marker is grep-able. Zero LLM dispatch needed. Implementation cost: ~80 LOC hook + ~120 LOC firing-test fixture (matching `settings-inline-env-prefix-detector.sh` shape).

## Deferred secondary candidates

### Priority 2 — SKILL (not proposed this run)

- `harness-firing-test-author` — codified procedure for writing firing-tests that simulate Windows spawn context (env -i, setsid, $PPID injection, command-string verbatim-shape). Defer until hook lands + 3 sessions of clean state confirm Pass 3 marker enforcement is workable.

### Priority 3 — CHARTER (NOT proposed; AP-23 LLM-Guardian creep risk)

- Charter invariant "harness hooks may not ship without spawn-context simulation in companion firing-test" — REJECT promotion here per Q-E3 priority + AP-23 doctrine. Hook enforcement is sufficient; charter revision requires explicit human approval (`PROJECT_CHARTER.md § Revision Protocol`) and would be over-formalization at 6 instances.

## Suggested implementation

S248 PRIORITY 2 (already queued in `checkpoints/latest.md:46`) → dev-subagent dispatch with this proposal as brief. Acceptance criteria:

1. `scripts/hooks/firing-test-spawn-context-lint.sh` exists + matches `settings-inline-env-prefix-detector.sh` style (set -uo pipefail; trap exit 0 ERR; WARN-only)
2. Companion firing-test at `scripts/hooks/firing-tests/firing-test-spawn-context-lint-fire-test.sh` covers Form-A (existing-good), Form-B (S247 known-bad), Form-C positional-arg (existing-good), missing-firing-test fixture, missing-SPAWN-CONTEXT-marker fixture
3. Settings.json `Stop` chain appends new hook entry
4. Run-all firing-test suite passes (current baseline 88/88 per S244)
5. Hook fires once against current repo: expected 0 violations (S247 fix already moved all 6 hooks to Form-C positional-arg)
6. New `agent-notes.md` entry L-S247-1 demoting all 6 prior instances under this rule's coverage

## Provenance trail

- All 6 instances cited with file + line + as-of date above
- Q-E3 priority directive: `agent-workspace/memory/observations/queued-grill-master.md § Q-E3` (hook FIRST)
- AP-23 doctrine + ritual-demotion mirror: `CLAUDE.md § Hard Rules` lines on tracking-retention + S99 Layer 5
- Existing partial guard limitation: `scripts/hooks/settings-inline-env-prefix-detector.sh:28-32` (Form-A only; Form-B uncaught)
- Sibling firing-test inventory: 88 existing fire-tests under `scripts/hooks/firing-tests/`; this proposal adds 1

## Confidence in proposal

HIGH. Single tight cluster, 6 instances, deterministic detector pattern proven viable by the sibling `settings-inline-env-prefix-detector.sh` already in production. Zero new LLM surface area.
