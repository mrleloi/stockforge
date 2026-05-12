---
observation_id: sandwich-dev-S244-lock-trap-fix
type: dev-session-report
created_at: 2026-05-10T00:00:00+07:00
session: S244 (sandwich-dev fresh-context per AP-1)
severity: HIGH-fix
status: COMPLETE
related: 2026-05-10-S243-parallel-finding-lock-trap-bug.md, drift-detector-S241b-phantom-dispatch-RC.md
---

# S244 sandwich-dev — single-claude-instance-lock.sh EXIT trap fix

## Files Changed

| File | Change | LOC delta |
|---|---|---|
| `scripts/hooks/single-claude-instance-lock.sh` | Deleted `trap 'rm -f "$LOCK"' EXIT` (line 30); updated comment block: STAGED→WIRED + added lock-lifetime explanation + S244 bug-fix note | -1 LOC (trap) +3 LOC (comment) = net +2 |
| `scripts/hooks/firing-tests/single-claude-instance-lock-fire-test.sh` | NEW — companion firing-test per Phase 3.5 §HH-G | +139 LOC |

## TASK 1 — Hook fix

Deleted `trap 'rm -f "$LOCK"' EXIT` from line 30. This trap fired when the bash hook script exited (line 31 `exit 0`), removing the lock microseconds after creation and defeating phantom-dispatch protection.

Updated comment block:
- Changed `WIRING STATUS: STAGED` to `WIRING STATUS: WIRED` (hook is wired at settings.json line 148 per S241b)
- Added `Lock lifetime = SESSION` clarification and explicit `Do NOT add EXIT trap here` warning

## TASK 2 — SessionEnd cleanup verification

**Finding: checkpoint claim ACCURATE — cleanup was already wired.**

`.claude/settings.json` SessionEnd chain, entry at line 238-240:
```json
{
  "type": "command",
  "command": "rm -f \"${CLAUDE_PROJECT_DIR:-.}/agent-workspace/memory/.claude-instance.lock\" 2>/dev/null; exit 0"
}
```

This exactly matches checkpoint S241b § line 48 claim: "Wired into `.claude/settings.json` SessionEnd chain to clean lock file." No action required. The design was always correct; only the implementation (EXIT trap) was wrong.

## TASK 3 — Companion firing-test

`scripts/hooks/firing-tests/single-claude-instance-lock-fire-test.sh` (139 LOC):

- mktemp -d sandbox + `trap 'rm -rf "$SANDBOX"' EXIT` cleanup per L-S174-1
- `CLAUDE_PROJECT_DIR=$SANDBOX` redirects lock target
- `RC=0; cmd || RC=$?` pattern for deliberate non-zero per L-S174-1
- TC1: first-run — no lock exists → hook writes lock + exits 0; content matches `session=...:pid:epoch`
- TC2: stale-lock — lock pre-written with PID 99999999 → hook overwrites + exits 0
- TC3: PENDING — live-sibling-blocked requires `tasklist` + live `claude.exe` process; marked `REQUIRES_TASKLIST`; deferred to manual S245 smoke
- TC4: SessionEnd cleanup contract — writes lock, runs exact `rm -f` command from settings.json, asserts lock removed

## TASK 4 — Test results

### Individual firing-test
```
PASS [TC1] first-run: exit 0, lock file exists, content='session=session-tc1:626056:1778420377' matches session=...:pid:epoch shape
PASS [TC2] stale-lock: exit 0, lock overwritten with new content='session=session-tc2:626056:1778420377'
PENDING [TC3] live-sibling-blocked: REQUIRES_TASKLIST + live claude.exe process (deferred to manual S245 smoke)
PASS [TC4] SessionEnd cleanup: rm -f removed lock as expected

=== single-claude-instance-lock-fire-test: PASS=3 FAIL=0 PENDING=1 (TC3) ===
    Non-pending TCs: 3/3
```

### Full suite regression
```
=== firing-test suite: 88/88 PASS (elapsed 233s) ===
```

88/88 — zero regression. +1 new firing-test over S188 baseline.

## TASK 2 finding summary

SessionEnd cleanup was correctly wired per checkpoint S241b claim. No gap found; no action needed. The checkpoint claim was accurate.

## Deviations from brief

None. All 5 tasks executed per brief. TC3 marked PENDING per explicit brief allowance ("TC3 marked PENDING with rationale").

## S244 PRIORITY 2 — 2-instance reproduction (deferred)

Manual smoke-test command for user:
1. Open a 2nd Claude Code window in the same project directory (`C:\htdocs\stockforge`)
2. Trigger a SessionStart (e.g., type any prompt)
3. Observe in the 2nd instance's hook output: `[BLOCK] Another claude.exe (pid=<N>) holds ... Refusing autonomous-continue spawn.` + exit 2

Why agent cannot run this internally: spawning a real second `claude.exe` process is not possible from within a single bash firing-test without a live claude.exe process to match against `tasklist //FI "PID eq $HOLDER_PID"`. The block path requires the holder PID to appear as `claude.exe` in the Windows process list, which only a real claude.exe provides.

Status: PRIORITY 2 deferred to S245 user manual verification.
