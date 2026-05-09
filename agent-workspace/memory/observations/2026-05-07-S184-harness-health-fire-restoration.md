---
observation_id: 2026-05-07-S184-harness-health-fire-restoration
type: focused-impl-log
session: S184
phase: 3.5
created_at: 2026-05-07
related_adr: D-042-S184-continue-injector-spawn-extraction
predecessor_observation: 2026-05-07-S183-harness-health-non-emission.md
status: SHIPPED-PENDING-PRODUCTION-VERIFICATION
---

# S184 — Continue-Injector Spawn Extraction → SessionStart Hook Chain Restoration

## Summary

S184 FOCUSED_IMPL applies S183-checkpointed Option A fix for the
harness-health-self-scan non-emission root cause. New hook
`continue-injector-spawn.sh` extracts the spawn block from
`session-start-bootstrap.sh:127-201` and is wired LAST in the SessionStart
chain. The empirically-observed Windows-specific chain truncation can no
longer suppress any downstream chain hook because there ARE no downstream
chain hooks after the spawn.

## Pre-state (post-S183)

- `.claude/settings.json` SessionStart matcher startup|resume|clear chain: 17 hooks
- `session-start-bootstrap.sh` at chain index 4 (line 156); spawn block at hook source lines 127-201
- `harness-health-self-scan.sh` at chain index 17 (line 208) — empirically suppressed in 60/60 source=clear+autonomous=true SessionStart events post-S173 ship
- Production-fire rate of harness-health-self-scan: 1/214 real events = 0.47%
- 12-signal continuous self-scan effectively non-emitting in production for ~12 hours

## Action sequence

| # | Action | File | LOC delta |
|---|---|---|---|
| 1 | Author standalone spawn hook | `scripts/hooks/continue-injector-spawn.sh` | +105 |
| 2 | Strip spawn block + update header | `scripts/hooks/session-start-bootstrap.sh` | -68 (204→136) |
| 3 | Append spawn hook LAST in SessionStart chain | `.claude/settings.json` | +5 |
| 4 | Author companion firing-test | `scripts/hooks/firing-tests/continue-injector-spawn-fire-test.sh` | +210 |

Net production: +37 LOC. Test code: +210 LOC. Test-to-code ratio 5.7x.

## Verification stack (4-fold)

### 1. Hook chain reorder verified

`.claude/settings.json` SessionStart matcher startup|resume|clear chain post-S184:
1. SessionStart echo log line
2. essential-routing-fields-verifier
3. working-memory-budget-audit
4. **session-start-bootstrap** ← spawn extracted out
5. vendor-api-probe
6. qa-pending-stale-mover
7. qa-answered-detector
8. sync-grilling-trigger
9. learning-queue-sweeper
10. ghost-work-audit
11. proposal-bundle-advisor
12. checkpoint-marker-cleanup-resume
13. in-flight-subagent-watcher
14. session-start-scan-unattested-observations
15. idle-escape-detector
16. phase-status-coherence
17. harness-health-self-scan
18. **continue-injector-spawn** ← NEW LAST (spawn truncation now harmless)

JSON parse validation: `node -e "JSON.parse(...)"` returns 0; settings.json
syntactically valid.

### 2. Bootstrap.sh refactor smoke-test

Empirical run with sandbox `$TMPDIR/agent-workspace/memory/checkpoints/latest.md`
+ `current-execution.md` containing `**autonomous_mode**: true` + payload
`{"hook_event_name":"SessionStart","source":"clear"}`:

- stdout: valid `{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"STOCKFORGE AUTONOMOUS RESUME: ..."}}` JSON ✓
- `.session-ready` written: `ready_at=2026-05-07T11:07:39+07:00` + `session_id=unknown` + `source=clear` ✓
- `.session-hooks.log` lines: `SessionStart-bootstrap source=clear latest_exists=yes` + `SessionStart-bootstrap injected additionalContext` ✓
- NO `spawned continue-injector` line emitted (spawn block successfully extracted) ✓

### 3. Continue-injector-spawn.sh standalone smoke-test

Empirical run with same sandbox + payload `{"hook_event_name":"SessionStart","source":"clear"}`:

- `.session-hooks.log` line: `continue-injector-spawn FIRED (source=clear + autonomous_mode=true)` ✓
- Spawn dispatch executed via detached `>/dev/null 2>&1 &` + `disown` (no observable test-output pollution)
- Hook exits 0 chain-gracefully ✓

### 4. Firing-test suite — individual + full regression

| Suite | TCs | Result |
|---|---|---|
| continue-injector-spawn-fire-test.sh (NEW) | 9 | 9/9 PASS |
| Full firing-test suite | 82 (was 81; +1 NEW) | **82/82 PASS** elapsed 223s |

Zero regression vs S181 D-041 baseline (81/81). The 9 NEW TCs cover:
- TC1: source=compact (out-of-scope) → exit 0, NO log entry
- TC2: source=clear, autonomous_mode=false, no override → SKIPPED
- TC3: source=clear, autonomous_mode=false, FORCE_CONTINUE_ON_CLEAR=1 → FIRED (override path)
- TC4: source=clear, autonomous_mode=true → FIRED
- TC5: source=resume → FIRED unconditionally
- TC6: source=startup, autonomous_mode=false → SKIPPED (race risk)
- TC7: source=startup, autonomous_mode=true → FIRED
- TC8: missing current-execution.md → autonomous defaults false → SKIPPED
- TC9: empty payload (no source field) → exit 0, NO log entry

## Production verification — pending

Cannot synthesize from agent context: Claude Code SessionStart hook chain is
triggered ONLY by real Claude Code session start (startup|resume|clear). The
truncation bug itself is a Claude-Code-Windows-specific behavior bypassing
bash semantics. Required observation: at next real `/clear` event, the
`.session-hooks.log` should contain ALL 18 chain-emission lines including the
final `harness-health-self-scan: state=...` summary.

Defense: smoke-test of refactored bootstrap + standalone spawn hook covers
chain-internal correctness. The empirically-validated S183 evidence #2
(source=empty case where no spawn occurs sees ALL 17 chain hooks emit in 3
seconds) proves the inverse — when no spawn, no truncation. Reordering spawn
to LAST means the truncation post-spawn is a no-op (no downstream targets).

## Counter-factual recovery

S183 quantified ~60+ missed harness-health-self-scan summaries since D-035
ship 2026-05-07 ~04:00 ICT (12-hour window × ~5 events/hour). Post-S184,
expected steady-state production-fire rate: ~100% of source=startup|resume|clear
SessionStart events (modulo separate UserPromptSubmit chain truncation which
remains unfixed; queued S185+ PRIORITY 2).

## Hard rules upheld

- L-S176-1 BINDING (real-state-derived fixtures): firing-test TC2/TC6 fixtures
  mirror actual `**autonomous_mode**: true` line format from
  `current-execution.md` (verified line 8 of real file)
- L-S174-1 RC-pattern: firing-test uses `mktemp -d` + `trap 'rm -rf "$TEMPDIR"' EXIT`
- Phase 3.5 §HH-G empirical-firing exemplar: spawn-hook ships with companion
  firing-test before activation in chain
- Phase 3.5 Hard Rule #2 (every hook ships with firing-test): satisfied
- verify_phase_before_next_phase: empirical IMPL evidence (4-fold verification
  stack) NOT silent advance
- harness_priority_one: harness signal-coverage fix executed before any product work
- autonomous_continue_no_self_pause: "continue" prompt picked + executed S183
  PRIORITY 1 verbatim without self-pause

## Hard locks honored

- 0 git commits this turn (CLAUDE.md hard rule)
- 0 charter file edits (T8 cool-down ≥2026-05-09 active)
- 0 constitution file writes (M-S173-1 deny holds)
- Q-B2: no AskUserQuestion fired (S183 checkpoint ratifies S184 PRIORITY 1; SCOPE-tier autonomous-full applies)

## Files this observation

- NEW `scripts/hooks/continue-injector-spawn.sh` (~105 LOC)
- NEW `scripts/hooks/firing-tests/continue-injector-spawn-fire-test.sh` (~210 LOC, 9 TCs)
- NEW `agent-workspace/memory/decisions/042-S184-continue-injector-spawn-extraction.md` (D-042 full 12-field)
- NEW `agent-workspace/memory/observations/2026-05-07-S184-harness-health-fire-restoration.md` (this file)
- EDITED `scripts/hooks/session-start-bootstrap.sh` (spawn block stripped 204→136 LOC)
- EDITED `.claude/settings.json` (1 chain entry appended)
- TO EDIT (next): `agent-workspace/memory/project.md` + `agent-workspace/memory/current-execution.md` + `agent-workspace/memory/checkpoints/latest.md` + `agent-workspace/memory/sessions/2026-05-07-session-184.md`

## End of S184 observation

Status: SHIPPED-PENDING-PRODUCTION-VERIFICATION. Empirical chain-internal
correctness verified via 4-fold stack. Production emission validation pending
next real `/clear` event. UserPromptSubmit chain truncation queued S185+
PRIORITY 2 separate root cause investigation.
