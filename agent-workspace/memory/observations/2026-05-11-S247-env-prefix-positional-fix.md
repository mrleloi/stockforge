# S247 — env-prefix hook command Form-B failure → Form-C positional-arg fix

**Date**: 2026-05-11 ~20:10+07:00
**Type**: Harness defect + fix (no product code touched)
**Recurrence class**: AP-23 "harness ships with verification-time defect because firing-test fixture didn't exercise actual-Windows-spawn-context edge case" — 6th instance

## Surfaced bug

At SessionStart boot, Claude Code TUI displayed 3× identical error:
```
SessionStart:startup hook error
Failed with non-blocking status code: /usr/bin/env: /usr/bin/env: cannot execute binary file
```

## Root cause

`.claude/settings.json` had 6 hook entries (3 SessionStart + 3 UserPromptSubmit) using `env CLAUDE_HOOK_EVENT=X bash "..."` syntax. On Windows + Git Bash:
- `/usr/bin/env` is a Windows PE32+ binary (not a typical POSIX env shim)
- Claude Code's hook executor wraps the command in a way that double-invokes env: `env env CLAUDE_HOOK_EVENT=X bash ...`
- The outer wrap fails with `cannot execute binary file` because the env binary path resolution under Claude Code's spawn wrapper trips on PE32+ format

The 3 errors matched exactly the 3 SessionStart hooks with env prefix; UserPromptSubmit hooks fail similarly on next user prompt.

## Saga (form ping-pong)

Per `agent-workspace/memory/checkpoints/2026-05-10-S244-close-handoff.md` (now archived; see also S245 in-flight checkpoint section):

- **Form A** (`VAR=val bash "script"`): failed S245 with `bash: VAR: No such file or directory` — Claude Code's outer wrapper does not parse inline-env-as-arg.
- **Form B** (`env VAR=val bash "script"`, applied S245 to fix Form A): failed this turn with `/usr/bin/env: cannot execute binary file`.
- **Form C** (positional arg, applied this turn): pass event as `$1`, no inline-env anywhere.

Both Form A and Form B work fine in direct bash invocation; only Claude Code's Windows hook executor breaks them. Local smoke tests didn't reproduce. The firing-test fixture exercises bash invocation but NOT Claude Code's actual hook-spawn path → AP-23 class.

## Fix applied

### settings.json (6 hook commands reformatted)

Before:
```json
"command": "env CLAUDE_HOOK_EVENT=SessionStart bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/idle-escape-detector.sh\""
```

After:
```json
"command": "bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/idle-escape-detector.sh\" SessionStart"
```

Lines affected: 204, 208, 212 (SessionStart variants) + 277, 281, 285 (UserPromptSubmit variants).

### Hook scripts (3 files, 1-line change each)

Before: `EVENT="${CLAUDE_HOOK_EVENT:-default}"`
After:  `EVENT="${1:-${CLAUDE_HOOK_EVENT:-default}}"`

- `scripts/hooks/idle-escape-detector.sh:26` (default UserPromptSubmit)
- `scripts/hooks/phase-status-coherence.sh:30` (default UserPromptSubmit)
- `scripts/hooks/harness-health-self-scan.sh:288` (default unknown)

Backward compatibility: env-var fallback preserved, so if some caller still uses `CLAUDE_HOOK_EVENT=X bash script.sh` form (or direct test invocation with no $1), it still works.

## Verification

```
bash scripts/hooks/idle-escape-detector.sh SessionStart       → exit 0
bash scripts/hooks/phase-status-coherence.sh SessionStart      → exit 0
bash scripts/hooks/harness-health-self-scan.sh SessionStart    → exit 0
bash scripts/hooks/idle-escape-detector.sh UserPromptSubmit    → exit 0
bash scripts/hooks/phase-status-coherence.sh UserPromptSubmit  → exit 0
bash scripts/hooks/harness-health-self-scan.sh UserPromptSubmit → exit 0
python -c "import json; json.load(open('.claude/settings.json'))" → JSON ok
```

Production verification deferred to next SessionStart fire (positional-arg form should emit zero hook-error lines in TUI).

## Files staged (NOT committed per CLAUDE.md hard rule)

- M `.claude/settings.json`
- M `scripts/hooks/idle-escape-detector.sh`
- M `scripts/hooks/phase-status-coherence.sh`
- M `scripts/hooks/harness-health-self-scan.sh`
- A `agent-workspace/memory/checkpoints/2026-05-10-S244-close-handoff.md` (archived from prior latest.md to enforce 8KB sub-cap; working-memory budget 24941B → 12821B / 20480B ceiling)
- M `agent-workspace/memory/checkpoints/latest.md` (rewritten to S247 turn summary)

## Promotion candidate

AP-23 6-instance threshold for "Windows-spawn-context firing-test gap" class is OVERDUE. S248 PRIORITY 2 = promote-rule subagent dispatch to formalize: **firing-tests MUST include a Claude-Code-spawn-equivalent simulation (not just bash invocation) for any hook command that uses inline-env or other non-default arg-passing syntax.**

Memory recorded at `C:\Users\PC\.ccs\instances\nathanleewindy\projects\C--htdocs-stockforge\memory\windows_env_prefix_hook_gotcha.md` (auto-memory layer; survives /clear).
