---
observation_id: sandwich-dev-S246-A-probe-ship
type: dev-delivery
created_at: 2026-05-10
session: S246-A
severity: INFO
status: DELIVERED
related:
  - agent-workspace/session-plans/pending/S246-lock-pid-secondary-fix-plan.md
  - agent-workspace/memory/observations/2026-05-10-S245-lock-pid-secondary-defect.md
  - scripts/hooks/lock-rc-probe.sh
---

# S246-A — probe delivery (lock-rc-probe.sh + settings.json wiring)

## What was shipped

### New file: `scripts/hooks/lock-rc-probe.sh`

- Total lines: 86 (including header comments and blank lines)
- Executable (non-comment, non-blank) lines: 59
- Plan target was ~30-50 LOC; deviation of ~9 lines is intentional — the node parse block
  captures all pid-variant field names the plan §2.1 requires (pid, ppid, parent_pid,
  process_id, ALL_KEYS for discovery). No structural deviation from plan.

Captures all 7 signals from plan §2.1:
1. `$$` (hook PID) — written as `hook_pid`
2. `$PPID` (S245 saw 1 — the key signal) — written as `hook_ppid`
3. `ps -ef` snapshot — full output for ancestor chain walk
4. `tasklist //V //FI "IMAGENAME eq claude.exe"` — full claude.exe list with command lines
5. `wmic process where "name='claude.exe'"` — ProcessId, ParentProcessId, CommandLine
6. All env vars matching `CLAUDE_*|STOCKFORGE_*|SESSION*` — sorted
7. Full stdin JSON payload (raw) + node-parsed field extraction

Output path pattern: `agent-workspace/memory/observations/lock-rc-probe-<YYYYMMDD-HHMMSS>-<hook_pid>.txt`
(timestamp + hook-PID suffix avoids collisions across rapid SessionStart fires during RUN2,
per plan §2.2).

### Modified file: `.claude/settings.json`

One new JSON hook object inserted IMMEDIATELY BEFORE the existing `single-claude-instance-lock.sh`
SessionStart hook entry (line 152 post-edit; was line 148 pre-edit):

```json
{
  "type": "command",
  "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/lock-rc-probe.sh\""
},
```

No other settings.json changes made.

## JSON re-validation result

Command: `python -c "import json; json.load(open('.claude/settings.json')); print('JSON valid')"`

Result: `JSON valid`

## Manual smoke evidence

Command run:
```
CLAUDE_PROJECT_DIR=/c/htdocs/stockforge bash scripts/hooks/lock-rc-probe.sh < /dev/null
```

Exit code: `0`

Probe output file created:
`agent-workspace/memory/observations/lock-rc-probe-20260510-220944-1057045.txt`

First 20 lines of probe output:
```
=== lock-rc-probe ===
timestamp=2026-05-10T22:09:44+07:00

--- SIGNAL 1: hook PID (1057045) ---
hook_pid=1057045

--- SIGNAL 2: hook PPID ($PPID) ---
hook_ppid=1057026

--- SIGNAL 3: ps -ef (full snapshot; look for claude.exe ancestor) ---
     UID     PID    PPID  TTY        STIME COMMAND
      PC 1057045 1057026 ?        22:09:44 bash /c/htdocs/stockforge/scripts/hooks/lock-rc-probe.sh 
      PC 1057052 1057045 ?        22:09:44 ps -ef 
      PC 1057026       1 ?        22:09:44 /usr/bin/bash -c -l ...
      ...

--- SIGNAL 4: tasklist //V (all claude.exe processes) ---
Image Name   PID   Session Name   Session#   Mem Usage   Status   User Name   CPU Time   Window Title
...
```

Lock file NOT modified: `agent-workspace/memory/.claude-instance.lock` contains
`session=unknown:1047673:1778425663` (different PID from probe run — probe correctly wrote
only to its diagnostic output file).

Note on dev-shell smoke vs real SessionStart: in this dev-shell run, `hook_ppid=1057026`
(a real parent bash, not 1). The S245 defect (`hook_ppid=1`) will surface when Claude Code
TUI fires SessionStart from its hook-dispatch mechanism. The probe is correctly wired to
capture the real PPID in that context.

## Provenance assertions

All behavioral assertions below cite exact file:line per CLAUDE.md hard rule:

- `CLAUDE_SESSION_ID` is empty in spawned context (resolves to "unknown" fallback):
  `agent-workspace/session-plans/pending/S246-lock-pid-secondary-fix-plan.md §1.3` which
  cites `scripts/hooks/profile-template-auto-populate.sh:38` (174/174 SessionStart events)
  and `agent-workspace/memory/agent-notes.md:547` (L-S48m-1 ACTIVE) and
  `agent-workspace/memory/agent-notes.md:591` (L-S108-1 ACTIVE).

- `$PPID == 1` in spawned bash hook subprocess (S245 empirical):
  `agent-workspace/memory/observations/2026-05-10-S245-lock-pid-secondary-defect.md:24`

- stdin JSON parse pattern (node) used by probe §SIGNAL 7 mirrors:
  `scripts/hooks/dispatch-jsonl-recorder.sh:21-35`

- Probe wired IMMEDIATELY BEFORE single-claude-instance-lock.sh per:
  `agent-workspace/session-plans/pending/S246-lock-pid-secondary-fix-plan.md §2.2`

- Probe MUST NOT modify real lock file:
  `agent-workspace/session-plans/pending/S246-lock-pid-secondary-fix-plan.md §2.2`
  ("Does NOT touch the real lock file")

- Probe MUST always exit 0:
  `agent-workspace/session-plans/pending/S246-lock-pid-secondary-fix-plan.md §2.2`
  ("never block, even on error reading any signal")

- No firing-test for probe:
  `agent-workspace/session-plans/pending/S246-lock-pid-secondary-fix-plan.md §2.4`
  ("probe is throwaway diagnostic")

## S246-B revert task (queue item)

Per plan §2.4: "MUST be reverted before S246-B fix lands."

S246-B dispatch MUST include as first task:
1. Remove the `lock-rc-probe.sh` hook entry from `.claude/settings.json` SessionStart chain.
2. Add "DIAGNOSTIC ONLY / NOT wired by default" comment block to `lock-rc-probe.sh` header
   (per plan §5 Task 2.3).
3. Verify settings.json JSON validity after revert.

## Staged files (not committed)

- `scripts/hooks/lock-rc-probe.sh` (new)
- `.claude/settings.json` (modified — 1 hook entry added)
- `agent-workspace/memory/observations/sandwich-dev-S246-A-probe-ship.md` (this file)
