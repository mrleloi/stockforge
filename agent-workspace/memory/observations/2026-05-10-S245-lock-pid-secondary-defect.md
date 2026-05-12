---
observation_id: 2026-05-10-S245-lock-pid-secondary-defect
type: harness-defect
created_at: 2026-05-10T~21:32+07:00
session: S245
severity: HIGH
status: OPEN
related: 2026-05-10-S243-parallel-finding-lock-trap-bug.md, sandwich-dev-S244-lock-trap-fix.md, drift-detector-S241b-phantom-dispatch-RC.md
---

# S245 secondary defect — single-claude-instance-lock holder_pid is unreliable (=1 instead of real claude.exe pid)

## Empirical evidence

LIVE RUN1 of validate_thesis spawned a 2nd claude.exe via subagent_transport. That 2nd claude's SessionStart fired the (now-patched, post-S244) `single-claude-instance-lock.sh`. Lock file content captured at 21:32+07:00:

```
session=unknown:1:1778421770
```

Format per hook line 29: `session=${CLAUDE_SESSION_ID:-unknown}:${SELF_PID}:$(date +%s)`.

- `${CLAUDE_SESSION_ID:-unknown}` resolved to `unknown` — the env var is not exported in the spawned bash context.
- `${SELF_PID}` = `${CLAUDE_PID:-$PPID}` (line 18) resolved to `1` — `CLAUDE_PID` not exported; `$PPID` of the bash hook script was 1 (likely because the spawn path detached from the actual claude.exe parent).

## Why this defeats the BLOCK check

Hook lines 20-27:
```bash
HOLDER_PID="$(awk -F: '{print $2}' "$LOCK" 2>/dev/null)"
if [ -n "$HOLDER_PID" ] && tasklist //FI "PID eq $HOLDER_PID" 2>/dev/null | grep -qi "claude.exe"; then
  echo "[BLOCK] Another claude.exe (pid=$HOLDER_PID) holds $LOCK. Refusing autonomous-continue spawn."
  export STOCKFORGE_AUTONOMOUS_DISABLE=1
  exit 2
fi
```

With `HOLDER_PID=1`:
- `tasklist //FI "PID eq 1"` returns either nothing or only Windows kernel processes (System Idle / System), never `claude.exe`
- `grep -qi "claude.exe"` returns false
- Condition is false → BLOCK does NOT fire → next claude.exe overwrites the lock + proceeds

**Net result**: the lock-trap fix at S244 prevented the trap from removing the lock, but the lock content is unusable as a holder-pid signal. Phantom-dispatch protection STILL functionally broken.

## RC candidates

1. **`CLAUDE_PID` env var not exported by Claude Code TUI to hook subprocess.** The hook should not rely on this var; use a more reliable mechanism.
2. **`$PPID` of bash hook script is 1 because the spawn path uses `setsid`, `nohup`, or a daemon-detach pattern.** Need to investigate how Claude Code spawns hooks on Windows / git-bash.
3. **The 2nd claude.exe's SessionStart hook chain runs in a context where the parent process tree is detached.** Possible — Claude Code subagent dispatch may use a Windows job-object pattern that orphans the bash subprocess.

## Mitigation candidates (S246+ harness queue)

- (a) Use `tasklist //V //FI "IMAGENAME eq claude.exe"` directly (without filtering by pid) and capture all claude.exe pids; lock content writes the FULL pid list at create time.
- (b) Use a different identity signal: e.g., ETW correlation ID, Windows job object handle, or a stable session uuid persisted in a separate file.
- (c) Cross-reference with `ps -ef` output (git-bash native) to find claude.exe ancestor chain instead of `$PPID`.
- (d) Have the lock file expire after N seconds (timestamp check) — if `$(date +%s) - lock_ts > 3600`, treat as stale even if BLOCK condition can't verify pid.

## Severity assessment

- **Phantom-dispatch protection** — STILL BROKEN (different RC from S243; both must be fixed for full protection).
- **Recurrence-class** with M-S189-1 and S243 lock-trap (= 3rd instance of harness-design-time-defect-surfaces-at-runtime class). AP-23 promotion threshold for that class now MET (3+ instances).
- **Impact on current LIVE re-run**: LOW for THIS run because no other claude.exe is racing to spawn. But the protection that's supposed to prevent future races is broken.

## Promotion implication

Combined with S243 lock-trap defect: this is now the 3rd instance of "harness hook ships with verification-time defect because firing-test fixture didn't exercise actual-Windows-environment edge case." Pattern:
- M-S189-1: HH-H.1 300s threshold designed for fast turns; real turns >300s.
- S243 lock-trap: line-30 trap removed lock immediately; firing-test didn't exercise lifetime-after-script-exit.
- S245 lock-pid: PPID=1 in spawned context; firing-test ran in dev-shell where PPID was bash session.

Promote-or-demote candidate L-S245+-1: "harness firing-tests must run in spawned-claude-context not dev-shell-context to catch env-var/process-tree defects." Promotion target: hook (additional CI step that re-runs firing-tests in spawned context) or skill (firing-test authoring checklist).

## Action queue

- **S245**: NOT-fixing this turn; LIVE RUN1 in progress. Promote-rule subagent already in flight on L-S240-5 cycle — may want to expand to include this finding.
- **S246+ PRIORITY 1**: investigate hook PPID=1 RC + ship fix + companion firing-test that runs in spawned-claude-context.
- **S246+ PRIORITY 2**: 2-instance manual smoke (still pending; now BOTH defects must be fixed for the smoke to PASS).

## Files referenced (read-only this turn)

- `scripts/hooks/single-claude-instance-lock.sh` lines 17-29 (post-S244)
- `agent-workspace/memory/.claude-instance.lock` (live state at 21:32 ICT)
